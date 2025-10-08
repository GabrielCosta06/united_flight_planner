// booking_confirmation.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flight.dart';
import 'manage_reservations.dart';
import '../core/app_theme.dart';


class BookingConfirmationScreen extends StatelessWidget {
  final String email;
  final Flight flight;
  final String reservationNumber; // Hardcoded (6 digits) temporarily.
  final String abbreviatedName2;
  final String passType;
  final String service;
  final String notification;
  final String totalPrice;

  const BookingConfirmationScreen({
    super.key,
    required this.email,
    required this.flight,
    this.reservationNumber = "123456", // Temporarily hardcoded
    required this.abbreviatedName2,
    required this.passType,
    required this.service,
    required this.notification,
    required this.totalPrice,
  });

  // A reusable widget for displaying content inside a Card with consistent style.
  Widget _buildSectionCard({required Widget child, EdgeInsets? padding}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat.jm();
    final departure = flight.departureTime;
    final arrival = flight.arrivalTime;
    final duration = arrival.difference(departure);
    final durationStr =
        "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";

    final flightInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flight, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "Flight Number: ",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Text(
              flight.flightNumber,
              style: GoogleFonts.inter(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "Date: ",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Text(
              dateFormat.format(departure),
              style: GoogleFonts.inter(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "Departure: ",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Text(
              timeFormat.format(departure),
              style: GoogleFonts.inter(),
            ),
            const SizedBox(width: 8),
            Text(
              " - Arrival: ",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Text(
              timeFormat.format(arrival),
              style: GoogleFonts.inter(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.flight_takeoff, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "From: ",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Text(
              flight.originAirportCode,
              style: GoogleFonts.inter(),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.flight_land, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "To: ",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Text(
              flight.destinationAirportCode,
              style: GoogleFonts.inter(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.timer, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "Duration: ",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Text(
              durationStr,
              style: GoogleFonts.inter(),
            ),
          ],
        ),
      ],
    );

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
                  'Booking confirmation',
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Booking Complete Message with check icon
          Card(
            color: Colors.green[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Booking complete\n\nYour travel itinerary has been created and queued for ticketing. A receipt will be sent to: $email",
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Flight Information Section with Title and Icon
          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      "Flight details",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                flightInfo,
              ],
            ),
          ),
          // Reservation Confirmation
          _buildSectionCard(
            child: Row(
              children: [
                const Icon(Icons.confirmation_number, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  "Confirmation: $reservationNumber",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // User Information Section
          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      "User Information",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text("Name: $abbreviatedName2",
                    style: GoogleFonts.inter(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Pass Type: $passType",
                    style: GoogleFonts.inter(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Service: $service",
                    style: GoogleFonts.inter(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Notifications: $notification",
                    style: GoogleFonts.inter(fontSize: 16)),
              ],
            ),
          ),
          // Total Price Section
          _buildSectionCard(
            child: Row(
              children: [
                const Icon(Icons.attach_money, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  "Total Price: ",
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  totalPrice,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Navigation rows using ListTile UI with icons.
          ListTile(
            leading: const Icon(Icons.work, color: AppColors.primary),
            title: Text(
              "Baggage details",
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Allowances, pricing, pay for bags and more",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              // TODO: Navigate to Baggage details screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.rule, color: AppColors.primary),
            title: Text(
              "Baggage rules and optional services",
              style: GoogleFonts.inter(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              // TODO: Navigate to Baggage rules and optional services screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppColors.primary),
            title: Text(
              "Add to calendar",
              style: GoogleFonts.inter(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              // TODO: Add functionality to add flight to calendar
            },
          ),
          const SizedBox(height: 24),
          // Manage Reservations Button navigating to ManageReservationsScreen.
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageReservationsScreen(
                      flight: flight,
                      reservationNumber: reservationNumber,
                      originCity: flight.originCity ?? '',
                      destinationCity: flight.destinationCity ?? '',
                      originAirportCode: flight.originAirportCode,
                      destinationAirportCode: flight.destinationAirportCode,
                      departureTime: flight.departureTime,
                      arrivalTime: flight.arrivalTime,
                      flightStatus: "on time", // Or "delayed" if needed.
                      abbreviatedName2: abbreviatedName2,
                    ),
                  ),
                );
              },
              child: Text(
                "Manage reservations",
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
