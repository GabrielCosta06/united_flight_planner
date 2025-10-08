import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/flight.dart';
import '../data/flight_data.dart' as flight_data;
import 'origin_screen.dart';
import 'flight_detail_screen.dart'; // Ensure FlightDetailScreen is imported
import '../core/app_theme.dart';


class TripsScreen extends StatefulWidget {
  final String currentEmployeeId;
  const TripsScreen({super.key, required this.currentEmployeeId});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 0,
        backgroundColor: AppColors.primary,
        elevation: 4,
        toolbarHeight: 50,
        centerTitle: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/globe.png',
                height: 150,
              ),
              const SizedBox(width: 10),
              Text(
                'My Trips',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                color: Colors.black.withValues(alpha: 0.3), // Shadow color
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 4), // Moves shadow down
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TripList(
                    tripType: TripType.upcoming,
                    currentEmployeeId: widget.currentEmployeeId),
                TripList(
                    tripType: TripType.past,
                    currentEmployeeId: widget.currentEmployeeId),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OriginScreen(
                currentEmployeeId: widget.currentEmployeeId,
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Enum for differentiating trip types.
enum TripType { upcoming, past }

/// TripList loads flight data and filters only the flights booked by the current employee.
class TripList extends StatefulWidget {
  final TripType tripType;
  final String currentEmployeeId;
  const TripList(
      {super.key, required this.tripType, required this.currentEmployeeId});

  @override
  State<TripList> createState() => _TripListState();
}

class _TripListState extends State<TripList> {
  bool _isLoading = true;
  List<Flight> _flights = [];

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  /// Loads flights from the fake flight data, filtering by the current employee and trip type.
  Future<void> _loadFlights() async {
    // Simulate network delay.
    await Future.delayed(const Duration(seconds: 1));

    // Load all flights from your fake data.
    List<Flight> allFlights =
        flight_data.fakeFlights.values.expand((list) => list).toList();

    // Filter flights that the current employee booked.
    List<Flight> bookedFlights = allFlights.where((flight) {
      return flight.confirmedPassengers.values.any(
          (passengerList) => passengerList.contains(widget.currentEmployeeId));
    }).toList();

    // Split flights into upcoming or past based on departure time.
    DateTime now = DateTime.now();
    if (widget.tripType == TripType.upcoming) {
      _flights = bookedFlights
          .where((flight) => flight.departureTime.isAfter(now))
          .toList();
    } else {
      _flights = bookedFlights
          .where((flight) => flight.departureTime.isBefore(now))
          .toList();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFlights,
      child: _isLoading
          ? Center(child: Image.asset('assets/images/loading.gif'))
          : _flights.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Text(
                        widget.tripType == TripType.upcoming
                            ? 'No upcoming trips booked.'
                            : 'No past trips booked.',
                        style: GoogleFonts.inter(),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _flights.length,
                  itemBuilder: (context, index) {
                    final flight = _flights[index];
                    return TripCard(
                      flight: flight,
                      currentEmployeeId: widget.currentEmployeeId,
                      tripType: widget.tripType,
                    );
                  },
                ),
    );
  }
}

/// A card widget to display individual trip details.
class TripCard extends StatelessWidget {
  final Flight flight;
  final String currentEmployeeId;
  final TripType tripType;

  const TripCard({
    super.key,
    required this.flight,
    required this.currentEmployeeId,
    required this.tripType,
  });

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Map Flight data to displayable values.
    String flightNumber = flight.flightNumber;
    String route =
        '${flight.originAirportCode} → ${flight.destinationAirportCode}';
    String date = _formatDate(flight.departureTime);
    String status = tripType == TripType.upcoming ? 'On Time' : 'Completed';

    Color statusColor;
    if (status == 'On Time') {
      statusColor = Colors.green;
    } else if (status == 'Delayed') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: FlightDetailScreen(
              flight: flight,
              currentEmployeeId: currentEmployeeId,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.flight, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flightNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      route,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(date, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
