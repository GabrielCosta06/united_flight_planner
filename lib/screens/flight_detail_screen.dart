import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/background.dart';
import '../models/flight.dart';
import '../widgets/priority_table.dart';
import '../widgets/seat_map.dart';
import 'select_travel_details_screen.dart';
import '../core/app_theme.dart';


class FlightDetailScreen extends StatefulWidget {
  final Flight flight;
  final String currentEmployeeId;

  const FlightDetailScreen({
    super.key,
    required this.flight,
    required this.currentEmployeeId,
  });

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  final Map<String, Map<String, String>> _priorityDetails = {
    'PS0E': {
      'boardingPriority': 'PS0E',
      'autoUpgrade': 'Yes',
      'description': 'Out-of-base deadheading Captain',
    },
    'SA1P': {
      'boardingPriority': 'SA1P',
      'autoUpgrade': 'Yes',
      'description': 'Example',
    },
  };

  final TextStyle _defaultTextStyle = GoogleFonts.inter();

  Map<String, int> _calculateFlightStats(Flight flight) {
    int booked = flight.confirmedPassengers.values.fold(
      0,
      (sum, list) => sum + list.length,
    );
    int checkedIn = flight.checkedInPassengers.values.fold(
      0,
      (sum, list) => sum + list.length,
    );
    int capacity =
        flight.seats.values.fold(0, (sum, seatCount) => sum + seatCount);
    int nonRevs = flight.standbyPassengers.values.fold(
      0,
      (sum, list) => sum + list.length,
    );
    return {
      'capacity': capacity,
      'booked': booked,
      'checkedIn': checkedIn,
      'available': flight.availableSeats,
      'nonRevs': nonRevs,
    };
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color iconColor,
      {bool highlight = false}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.primary : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFlightHeader(Flight flight) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flight.flightNumber,
              style:
                  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat.jm().format(flight.departureTime)} - ${DateFormat.jm().format(flight.arrivalTime)}',
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(flight.originAirportCode,
                    style: GoogleFonts.inter(fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.black54),
                const SizedBox(width: 8),
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 4),
                Text(flight.destinationAirportCode,
                    style: GoogleFonts.inter(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              flight.aircraft,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Passenger: ${widget.currentEmployeeId[0].toUpperCase()}${widget.currentEmployeeId.substring(1)}',
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityInfo(BuildContext context, String priority) {
    final details = _priorityDetails[priority] ??
        {
          'boardingPriority': priority,
          'autoUpgrade': 'No',
          'description': 'No information available',
        };
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.4),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                },
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    children:
                        ['Boarding Priority', 'Auto Upgrade', 'Description']
                            .map((header) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    header,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                  ),
                  TableRow(
                    children: [
                      details['boardingPriority']!,
                      details['autoUpgrade']!,
                      details['description']!,
                    ]
                        .map((text) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(text, style: _defaultTextStyle),
                            ))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Close', style: _defaultTextStyle),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSeatMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeatMapScreen(
          flight: widget.flight,
          currentEmployeeId: widget.currentEmployeeId,
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message, style: GoogleFonts.inter(fontSize: 16)),
      ),
    );
  }

  void _showBoardingTotals(BuildContext context) {
    final stats = _calculateFlightStats(widget.flight);
    _showBottomSheet(
      context,
      'Boarding Totals: ${stats['booked']} passengers booked (Not implemented yet)',
    );
  }

  void _showPotentialMisconnects(BuildContext context) =>
      _showBottomSheet(context, 'Potential Misconnects (Not implemented yet)');

  void _showFlightStatus(BuildContext context) => _showBottomSheet(context,
      'Flight Status for flight ${widget.flight.flightNumber} (Not implemented yet)');

  @override
  Widget build(BuildContext context) {
    final stats = _calculateFlightStats(widget.flight);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: AppColors.primary,
        elevation: 4,
        toolbarHeight: 50,
        centerTitle: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Image.asset(
                'assets/images/globe.png',
                height: 150,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  'Flight ${widget.flight.flightNumber} Details',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Background(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFlightHeader(widget.flight),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Row(
                      children: [
                        _buildStatItem('Capacity', stats['capacity']!,
                            Icons.event_seat, Colors.grey),
                        _buildStatItem('Booked', stats['booked']!,
                            Icons.bookmark, Colors.green),
                        _buildStatItem('Checked-In', stats['checkedIn']!,
                            Icons.check_circle, Colors.blue),
                        _buildStatItem('Available', stats['available']!,
                            Icons.event_available, Colors.orange),
                        _buildStatItem('Standbys', stats['nonRevs']!,
                            Icons.person_outline, AppColors.primary,
                            highlight: true),
                      ],
                    ),
                  ),
                ),
                DefaultTabController(
                  length: 3,
                  initialIndex: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TabBar(
                        isScrollable: true,
                        padding: EdgeInsets.zero,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        indicatorPadding: EdgeInsets.zero,
                        tabAlignment: TabAlignment.start,
                        labelStyle:
                            GoogleFonts.inter(fontWeight: FontWeight.bold),
                        unselectedLabelStyle: GoogleFonts.inter(),
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.black,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(text: 'Cabin seat'),
                          Tab(text: 'Flight deck jumpseat'),
                          Tab(text: 'Cabin jumpseat'),
                        ],
                      ),
                      SizedBox(
                        height: 350,
                        child: TabBarView(
                          children: [
                            PriorityTable(
                              priorityDetails: _priorityDetails,
                              standbyPassengers:
                                  widget.flight.standbyPassengers,
                              currentEmployeeId: widget.currentEmployeeId,
                              showPriorityInfo: (priority) =>
                                  _showPriorityInfo(context, priority),
                            ),
                            Center(
                              child: Text(
                                "Flight deck jumpseat not implemented yet",
                                style: GoogleFonts.inter(),
                              ),
                            ),
                            Center(
                              child: Text(
                                "Cabin jumpseat not implemented yet",
                                style: GoogleFonts.inter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // The list of action items.
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        title:
                            Text("View seat map", style: GoogleFonts.inter()),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showSeatMap(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text("View boarding totals",
                            style: GoogleFonts.inter()),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showBoardingTotals(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text("View potential misconnects",
                            style: GoogleFonts.inter()),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showPotentialMisconnects(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text("View flight status",
                            style: GoogleFonts.inter()),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showFlightStatus(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Instead of finalizing the booking, this button navigates to travel details selection.
                if (!widget.flight.confirmedPassengers.values
                    .any((list) => list.contains(widget.currentEmployeeId)))
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        // Navigate to SelectTravelDetailsScreen to let the user choose additional details.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectTravelDetailsScreen(
                              currentEmployeeId: widget.currentEmployeeId,
                              flight: widget.flight,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Select trip',
                        style: GoogleFonts.inter(
                            fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlightStatusIndicator extends StatelessWidget {
  final String status;
  const FlightStatusIndicator({super.key, required this.status});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'on time':
        return Colors.green;
      case 'overbooked':
        return Colors.yellow;
      case 'delayed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
