// manage_reservations.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'flight_status_screen.dart';
import '../models/flight.dart';
import 'booking_service.dart';
import '../core/app_theme.dart';


class ManageReservationsScreen extends StatefulWidget {
  final Flight flight;
  final String reservationNumber;
  final String originCity;
  final String destinationCity;
  final String originAirportCode;
  final String destinationAirportCode;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String flightStatus; // "on time" or "delayed"
  final String abbreviatedName2; // Employee abbreviated name

  const ManageReservationsScreen({
    super.key,
    required this.flight,
    required this.reservationNumber,
    required this.originCity,
    required this.destinationCity,
    required this.originAirportCode,
    required this.destinationAirportCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.flightStatus,
    required this.abbreviatedName2,
  });

  @override
  State<ManageReservationsScreen> createState() =>
      _ManageReservationsScreenState();
}

class _ManageReservationsScreenState extends State<ManageReservationsScreen> {
  bool _isFlightDetailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Format departure and arrival times and dates.
    final departureTimeStr = _formatTime(widget.departureTime);
    final arrivalTimeStr = _formatTime(widget.arrivalTime);
    final departureDateStr = _formatDate(widget.departureTime);
    final arrivalDateStr = _formatDate(widget.arrivalTime);

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
                  'Manage reservations',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with origin and destination and confirmation.
            Text(
              "${widget.originCity} to ${widget.destinationCity} (${widget.originAirportCode} to ${widget.destinationAirportCode})",
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "United confirmation: ${widget.reservationNumber}",
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Flight card.
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flight number and status.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Flight ${widget.flight.flightNumber}",
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.flightStatus,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              color:
                                  widget.flightStatus.toLowerCase() == "on time"
                                      ? Colors.green
                                      : Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Departure and arrival information.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Dep: $departureTimeStr",
                                style: GoogleFonts.inter(fontSize: 16)),
                            Text(departureDateStr,
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: Colors.grey)),
                            Text(
                                "${widget.originAirportCode} (${widget.originCity})",
                                style: GoogleFonts.inter(fontSize: 14)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Arr: $arrivalTimeStr",
                                style: GoogleFonts.inter(fontSize: 16)),
                            Text(arrivalDateStr,
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: Colors.grey)),
                            Text(
                                "${widget.destinationAirportCode} (${widget.destinationCity})",
                                style: GoogleFonts.inter(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Operated by.
                    Text(
                      "Operated by United Airlines",
                      style: GoogleFonts.inter(
                          fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    // Expandable Flight Details.
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFlightDetailsExpanded = !_isFlightDetailsExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Flight Details",
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Icon(_isFlightDetailsExpanded
                              ? Icons.expand_less
                              : Icons.expand_more),
                        ],
                      ),
                    ),
                    if (_isFlightDetailsExpanded)
                      Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "View flight status",
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: AppColors.primary),
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Pop up the FlightStatusScreen.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FlightStatusScreen(
                                    currentEmployeeId: widget.abbreviatedName2,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              widget.abbreviatedName2,
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "This flight is waitlisted.",
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Manage your trip section.
            Text(
              "Manage your trip",
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Two buttons: Change flight and Check in.
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      textStyle: TextStyle(color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // TODO: Implement change flight action.
                    },
                    child: Text("Change flight",
                        style: GoogleFonts.inter(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      textStyle: TextStyle(color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // TODO: Implement check in action.
                    },
                    child: Text("Check in",
                        style: GoogleFonts.inter(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // List of management options.
            _buildManagementOption("Edit traveler information",
                "Contact info, frequent flyer, KTN and more"),
            _buildManagementOption("Baggage details",
                "Allowances, pricing, pay for bags, and more"),
            _buildManagementOption(
                "Add to calendar", "Set a calendar reminder for your trip"),
            _buildManagementOption(
                "Email receipt", "Send a copy to your email"),
            _buildManagementOption(
                "View standby list", "See where you are at on the list"),
            _buildManagementOption(
                "Cancel flight", "View your cancellation options"),
            const SizedBox(height: 24),
            // Cancel reservation button.
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  final bookingService = BookingService();
                  // Use the correct seat class key (e.g., 'United Economy') that was used during booking.
                  bool success = bookingService.unbookSeat(
                      widget.flight, 'United Economy', widget.abbreviatedName2);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Reservation canceled successfully.",
                            style: GoogleFonts.inter()),
                      ),
                    );
                    // Navigate back to the main page by popping until the first route.
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Failed to cancel reservation. Please try again.",
                            style: GoogleFonts.inter()),
                      ),
                    );
                  }
                },
                child: Text("Cancel reservation",
                    style:
                        GoogleFonts.inter(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOption(String title, String subtitle) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: GoogleFonts.inter(fontSize: 16)),
          subtitle: Text(subtitle,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to the appropriate page or implement action.
          },
        ),
        const Divider(),
      ],
    );
  }

  String _formatTime(DateTime time) {
    // Returns formatted time like "14:05"
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime date) {
    // Returns formatted date like "Mar 28"
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}";
  }
}
