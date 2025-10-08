import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flight.dart';
import 'review_trip.dart';

const Color unitedBlue = Color(0xFF005DAA);

class SelectTravelDetailsScreen extends StatefulWidget {
  final String currentEmployeeId;
  final Flight? flight;

  const SelectTravelDetailsScreen({
    super.key,
    required this.currentEmployeeId,
    this.flight,
  });

  @override
  _SelectTravelDetailsScreenState createState() =>
      _SelectTravelDetailsScreenState();
}

class _SelectTravelDetailsScreenState extends State<SelectTravelDetailsScreen> {
  bool travelingWithWorkCrew = false;
  String? selectedPassType;
  String? selectedService;
  String? selectedNotification;

  final List<String> passTypeOptions = [
    "Personal",
    "Crew relocation",
    "Jumpseat",
    "Fee-waived SA9W",
  ];

  final List<String> serviceOptions = [
    "Economy",
    "Premium Plus",
    "Polaris",
  ];

  final List<String> notificationOptions = [
    "Email and text",
    "Email",
    "Text",
  ];

  @override
  void initState() {
    super.initState();
    selectedPassType = passTypeOptions.first;
    selectedService = serviceOptions.first;
    selectedNotification = notificationOptions.first;
  }

  /// Reusable card widget
  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildFlightSelectedSection() {
    if (widget.flight == null) return const SizedBox();

    final flight = widget.flight!;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat.jm();

    // Convert times to UTC to correctly compute duration across time zones
    final departureUtc = flight.departureTime.toUtc();
    final arrivalUtc = flight.arrivalTime.toUtc();
    final duration = arrivalUtc.difference(departureUtc);
    final durationStr =
        "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight, color: unitedBlue),
              const SizedBox(width: 8),
              Text(
                "Flight Selected",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          Text(
            "Date: ${dateFormat.format(flight.departureTime)}",
            style: GoogleFonts.inter(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: unitedBlue),
                  const SizedBox(width: 4),
                  Text(
                    "Departure: ${timeFormat.format(flight.departureTime)}",
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: unitedBlue),
                  const SizedBox(width: 4),
                  Text(
                    "Arrival: ${timeFormat.format(flight.arrivalTime)}",
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flight_takeoff, size: 16, color: unitedBlue),
                  const SizedBox(width: 4),
                  Text(
                    "From: ${flight.originAirportCode}",
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.flight_land, size: 16, color: unitedBlue),
                  const SizedBox(width: 4),
                  Text(
                    "To: ${flight.destinationAirportCode}",
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: unitedBlue),
              const SizedBox(width: 4),
              Text(
                "Duration: $durationStr",
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// TSA notice section with an info icon.
  Widget _buildTravelersSelectionsSection() {
    const tsaNotice =
        '''TSA requires travelers' name, gender, and birthdate to match the traveler's document used on the day of travel. Identification information that may have previously been entered that does not match you or your travelers' profiles may cause delays at the security checkpoint. You may review your travel profile and document gender, Known Traveler Number, or redress Number by going to your Personal Profile, or to Traveler profile for eligible pass riders. Changes to your saved information can be made in your employeeRES profile. Go to employeeRES.''';

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: unitedBlue),
              const SizedBox(width: 8),
              Text(
                "Selections by Travelers",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          Text(
            tsaNotice,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// A reusable dropdown field widget.
  Widget _buildDropdownField({
    required String title,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: Container(height: 1, color: Colors.grey),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: GoogleFonts.inter()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Form section for travel details.
  Widget _buildTravelDetailsForm() {
    final employeeId = widget.currentEmployeeId;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: unitedBlue),
              const SizedBox(width: 8),
              Text(
                "$employeeId (Employee)",
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                activeColor: unitedBlue,
                value: travelingWithWorkCrew,
                onChanged: (value) {
                  setState(() {
                    travelingWithWorkCrew = value ?? false;
                  });
                },
              ),
              Text(
                "Traveling with a work crew",
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            title: "Pass type:",
            value: selectedPassType,
            options: passTypeOptions,
            onChanged: (value) {
              setState(() {
                selectedPassType = value;
              });
            },
          ),
          _buildDropdownField(
            title: "Service:",
            value: selectedService,
            options: serviceOptions,
            onChanged: (value) {
              setState(() {
                selectedService = value;
              });
            },
          ),
          _buildDropdownField(
            title: "Day-of-travel notification:",
            value: selectedNotification,
            options: notificationOptions,
            onChanged: (value) {
              setState(() {
                selectedNotification = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Navigation helper for detail screens.
  void navigateToDetail(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'Travel details',
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
                color: Colors.black54,
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFlightSelectedSection(),
              _buildTravelersSelectionsSection(),
              const SizedBox(height: 16),
              _buildTravelDetailsForm(),
              const SizedBox(height: 24),
              // Navigation list tiles with icons.
              ListTile(
                leading: const Icon(Icons.info, color: unitedBlue),
                title: Text(
                  "KTN / redress number / gender",
                  style: GoogleFonts.inter(),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => navigateToDetail("KTN / redress number / gender"),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.support_agent, color: unitedBlue),
                title: Text(
                  "Travel needs",
                  style: GoogleFonts.inter(),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => navigateToDetail("Travel needs"),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.child_friendly, color: unitedBlue),
                title: Text(
                  "Add lap child",
                  style: GoogleFonts.inter(),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => navigateToDetail("Add lap child"),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    backgroundColor: unitedBlue,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewTripScreen(
                          currentEmployeeId: widget.currentEmployeeId,
                          flight: widget.flight,
                          passType: selectedPassType!,
                          service: selectedService!,
                          notification: selectedNotification!,
                          abbreviatedName2: widget.currentEmployeeId,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Next",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dummy detail screen for navigation.
class DetailScreen extends StatelessWidget {
  final String title;

  const DetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.inter(),
        ),
        backgroundColor: unitedBlue,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "This is the $title detail screen.",
          style: GoogleFonts.inter(fontSize: 16),
        ),
      ),
    );
  }
}
