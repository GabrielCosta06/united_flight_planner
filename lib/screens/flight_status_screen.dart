// flight_status_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/flight.dart';
import '../data/flight_data.dart' as flight_data;
import '../widgets/seat_map.dart';
import 'important_notice_screen.dart';
import '../core/app_theme.dart';


class FlightStatusScreen extends StatefulWidget {
  final String currentEmployeeId;
  final Flight? flight;
  final Map<String, dynamic>? checkInData;

  const FlightStatusScreen({
    super.key,
    required this.currentEmployeeId,
    this.flight,
    this.checkInData,
  });

  @override
  State<FlightStatusScreen> createState() => _FlightStatusScreenState();
}

class _FlightStatusScreenState extends State<FlightStatusScreen> {
  Flight? selectedFlight;
  bool _isLoading = true;
  Map<String, dynamic>? cabinSeatAssignments;
  List<Flight> upcomingFlights = [];

  @override
  void initState() {
    super.initState();
    if (widget.flight != null) {
      // If a flight was passed, use it and skip loading flights.
      selectedFlight = widget.flight;
      cabinSeatAssignments =
          generateDummySeatAssignmentsByCabin(selectedFlight!);
      _isLoading = false;
    } else {
      _loadFlights();
    }
  }

  Future<void> _loadFlights() async {
    await Future.delayed(const Duration(seconds: 1));
    final allFlights =
        flight_data.fakeFlights.values.expand((list) => list).toList();

    upcomingFlights = allFlights.where((flight) {
      bool isUpcoming = flight.departureTime.isAfter(DateTime.now());
      bool isBooked = flight.confirmedPassengers.values
          .any((list) => list.contains(widget.currentEmployeeId));
      return isUpcoming && isBooked;
    }).toList();

    if (upcomingFlights.isNotEmpty) {
      selectedFlight = upcomingFlights.first;
      cabinSeatAssignments =
          generateDummySeatAssignmentsByCabin(selectedFlight!);
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// When the user taps on "Check In" and if within 24 hours of departure,
  /// navigate to the ImportantNoticeScreen, passing all necessary data.
  void _handleCheckIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportantNoticeScreen(
          currentEmployeeId: widget.currentEmployeeId,
          flight: selectedFlight,
          checkInData: {
            // Add any additional check-in data you need here.
          },
        ),
      ),
    );
  }

  void _onFlightSelected(Flight flight) {
    setState(() {
      selectedFlight = flight;
      cabinSeatAssignments = generateDummySeatAssignmentsByCabin(flight);
    });
  }

  Widget _buildFlightSelection() {
    if (upcomingFlights.length < 2) return const SizedBox();
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: upcomingFlights.length,
        itemBuilder: (context, index) {
          final flight = upcomingFlights[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: FlightOptionCard(
              flight: flight,
              isSelected: flight == selectedFlight,
              onTap: () => _onFlightSelected(flight),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckInSection() {
    if (selectedFlight == null) return const SizedBox();
    final now = DateTime.now();
    final diff = selectedFlight!.departureTime.difference(now);
    final canCheckIn = diff.inHours <= 24 && diff.inSeconds > 0;
    final checkInText = canCheckIn
        ? 'You can check in now.'
        : 'Check in is available only 24 hours before departure.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          checkInText,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canCheckIn ? AppColors.primary : Colors.grey,
            foregroundColor: Colors.white,
          ),
          onPressed: canCheckIn ? _handleCheckIn : null,
          child: Text(
            'Check In',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedFlight == null
              ? Center(
                  child: Text(
                    'No flight status available.\nPlease, book a flight first.',
                    style: GoogleFonts.inter(),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFlightSelection(),
                      FlightDetailCard(
                        flight: selectedFlight!,
                        currentEmployeeId: widget.currentEmployeeId,
                      ),
                      const SizedBox(height: 16),
                      _buildCheckInSection(),
                      const SizedBox(height: 16),
                      _buildSeatMap(),
                    ],
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
              'Flight Status',
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
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatMap() {
    final cabinEntries =
        (cabinSeatAssignments as Map<String, dynamic>).entries.toList();
    return Column(
      children: List.generate(cabinEntries.length, (index) {
        final entry = cabinEntries[index];
        String cabin = entry.key;
        final data = entry.value;
        int seatCount = selectedFlight!.seats[cabin] ?? data.assignments.length;
        String? currentUserSeat = data.assignments[widget.currentEmployeeId];
        final bool isFirstCabin = index == 0;
        final bool isLastCabin = index == cabinEntries.length - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: RealisticCabinSeatMap(
            cabin: cabin,
            seatCount: seatCount,
            assignments: data.assignments,
            bookedSeat: currentUserSeat,
            connectingPassengerIds:
                selectedFlight!.connectingPassengerIds ?? [],
            startingRow: data.startingRow,
            isFirstCabin: isFirstCabin,
            isLastCabin: isLastCabin,
          ),
        );
      }),
    );
  }
}

class FlightOptionCard extends StatelessWidget {
  final Flight flight;
  final bool isSelected;
  final VoidCallback onTap;

  const FlightOptionCard({
    super.key,
    required this.flight,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('HH:mm').format(flight.departureTime);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flight ${flight.flightNumber}',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.airplanemode_active,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  flight.aircraft,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Departs at $formattedTime',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class FlightDetailCard extends StatelessWidget {
  final Flight flight;
  final String currentEmployeeId;
  const FlightDetailCard({
    super.key,
    required this.flight,
    required this.currentEmployeeId,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = getFlightStatus(flight);
    final formattedTime = DateFormat('HH:mm').format(flight.departureTime);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flight.flightNumber,
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.airplanemode_active, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  flight.aircraft,
                  style: GoogleFonts.inter(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 4),
                _buildLocationChip(flight.originAirportCode),
                const Icon(Icons.arrow_forward, color: Colors.black45),
                _buildLocationChip(flight.destinationAirportCode),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.deepPurple),
                const SizedBox(width: 4),
                Text('Departure: $formattedTime',
                    style: GoogleFonts.inter(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Status: ',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                FlightStatusIndicator(status: statusInfo.status),
              ],
            ),
            if (statusInfo.status.toLowerCase() == "delayed" &&
                statusInfo.delayReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Delay Info: ${statusInfo.delayReason}',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationChip(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.yellow.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        code,
        style: GoogleFonts.inter(fontSize: 16),
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

FlightStatus getFlightStatus(Flight flight) {
  if (flight.flightNumber == 'UA102') {
    return FlightStatus("Delayed", "Weather conditions causing delay.");
  } else if (flight.flightNumber == 'UA304') {
    return FlightStatus("Overbooked", "Excess passenger load detected.");
  }
  return FlightStatus("On Time");
}

class FlightStatus {
  final String status;
  final String? delayReason;
  FlightStatus(this.status, [this.delayReason]);
}
