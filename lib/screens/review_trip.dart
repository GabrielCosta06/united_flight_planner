// review_trip.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flight.dart';
import 'booking_service.dart';
import 'booking_confirmation.dart';

const Color unitedBlue = Color(0xFF005DAA);

class ReviewTripScreen extends StatefulWidget {
  final String currentEmployeeId;
  final Flight? flight;
  final String passType;
  final String service;
  final String notification;
  final String abbreviatedName2;

  const ReviewTripScreen({
    super.key,
    required this.currentEmployeeId,
    this.flight,
    required this.passType,
    required this.service,
    required this.notification,
    required this.abbreviatedName2,
  });

  @override
  _ReviewTripScreenState createState() => _ReviewTripScreenState();
}

class _ReviewTripScreenState extends State<ReviewTripScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  final cardMargin = const EdgeInsets.only(bottom: 16);
  final cardPadding = const EdgeInsets.all(16.0);
  final borderRadius = 12.0;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget _formatFlightInfo() {
    if (widget.flight == null) {
      return Text("No flight selected.", style: GoogleFonts.inter());
    }

    final flight = widget.flight!;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat.jm();
    final departure = flight.departureTime;
    final arrival = flight.arrivalTime;
    final duration = arrival.difference(departure);
    final durationStr =
        "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";

    final boldStyle =
        GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14);
    final normalStyle = GoogleFonts.inter(fontSize: 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flight, color: unitedBlue),
            const SizedBox(width: 8),
            Text("Flight Number: ", style: normalStyle),
            Text(flight.flightNumber, style: boldStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.calendar_today, color: unitedBlue),
            const SizedBox(width: 8),
            Text("Date: ", style: normalStyle),
            Text(dateFormat.format(departure), style: boldStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule, color: unitedBlue),
            const SizedBox(width: 8),
            Text("Departure: ", style: normalStyle),
            Text(timeFormat.format(departure), style: boldStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule, color: unitedBlue),
            const SizedBox(width: 8),
            Text("Arrival: ", style: normalStyle),
            Text(timeFormat.format(arrival), style: boldStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: unitedBlue),
            const SizedBox(width: 8),
            Text("From: ", style: normalStyle),
            Text(flight.originAirportCode, style: boldStyle),
            const SizedBox(width: 24),
            const Icon(Icons.flight_land, color: unitedBlue),
            const SizedBox(width: 8),
            Text("To: ", style: normalStyle),
            Text(flight.destinationAirportCode, style: boldStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.timelapse, color: unitedBlue),
            const SizedBox(width: 8),
            Text("Duration: ", style: normalStyle),
            Text(durationStr, style: boldStyle),
          ],
        ),
      ],
    );
  }

  Future<void> _bookItinerary() async {
    if (widget.flight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('No flight selected to book.', style: GoogleFonts.inter()),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a delay for booking processing.
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a booking call.
    final String preferredCabin = widget.flight!.aircraft.contains("777-200")
        ? 'United Economy'
        : 'United Economy';
    final BookingService bookingService = BookingService();
    bool success = bookingService.bookSeat(
      widget.flight!,
      preferredCabin,
      widget.currentEmployeeId,
    );

    setState(() {
      _isLoading = false;
    });

    // Show the result dialog with animation.
    await _showResultDialog(success);

    if (success) {
      final bool isDomestic =
          widget.flight == null || !widget.flight!.flightNumber.contains("INT");
      final String totalPrice = isDomestic ? "\$0.00" : "\$500.00";
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            email: _emailController.text,
            flight: widget.flight!,
            abbreviatedName2: widget.abbreviatedName2,
            passType: widget.passType,
            service: widget.service,
            notification: widget.notification,
            totalPrice: totalPrice,
          ),
        ),
      );
    }
  }

  Future<void> _showResultDialog(bool success) async {
    // Show the dialog.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResultDialog(success: success),
    );

    // Wait for 2 seconds, then close the dialog using the root navigator.
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDomestic =
        widget.flight == null || !widget.flight!.flightNumber.contains("INT");
    final String totalPrice = isDomestic ? "\$0.00" : "\$500.00";
    final Widget flightInfo = _formatFlightInfo();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: unitedBlue,
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
                  'Review trip',
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
            gradient: const LinearGradient(
              colors: [unitedBlue, Color.fromARGB(255, 23, 0, 65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
            // Total Price Section
            Card(
              elevation: 3,
              margin: cardMargin,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: cardPadding,
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: unitedBlue),
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
                          color: unitedBlue),
                    ),
                  ],
                ),
              ),
            ),
            // Flight Information Section
            Card(
              elevation: 3,
              margin: cardMargin,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Flight Information",
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    flightInfo,
                  ],
                ),
              ),
            ),
            // User Information Section
            Card(
              elevation: 3,
              margin: cardMargin,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "User Information",
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          const Icon(Icons.account_circle, color: unitedBlue),
                      title: Text(
                        "Name: ${widget.abbreviatedName2}",
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.card_travel, color: unitedBlue),
                      title: Text(
                        "Pass Type: ${widget.passType}",
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.miscellaneous_services,
                          color: unitedBlue),
                      title: Text(
                        "Service: ${widget.service}",
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          const Icon(Icons.notifications, color: unitedBlue),
                      title: Text(
                        "Notifications: ${widget.notification}",
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Email Address Input
            Card(
              elevation: 3,
              margin: cardMargin,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: cardPadding,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: GoogleFonts.inter(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email, color: unitedBlue),
                  ),
                ),
              ),
            ),
            // Terms and Conditions
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: cardPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: unitedBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "By selecting 'Book itinerary', you understand and agree to United's pass travel guidelines, United's dangerous goods policy, terms and conditions in United's Contract of Carriage and the collection, processing and transfer of your information to the United States for handling in accordance with United's privacy policy.",
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Book Itinerary Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: unitedBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                icon: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, color: Colors.white),
                label: Text(
                  _isLoading ? "Booking..." : "Book Itinerary",
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                ),
                onPressed: _isLoading ? null : _bookItinerary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom result dialog widget with animation.
class _ResultDialog extends StatefulWidget {
  final bool success;

  const _ResultDialog({super.key, required this.success});

  @override
  __ResultDialogState createState() => __ResultDialogState();
}

class __ResultDialogState extends State<_ResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipOval(
            child: Container(
              width: 165, // Slightly larger for a more prominent circle.
              height: 165,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.success ? Icons.check_circle : Icons.error,
                    color: widget.success ? Colors.green : Colors.red,
                    size: 80,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.success ? "Successful!" : "Failed",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
