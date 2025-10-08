import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/background.dart';
import 'flight_detail_screen.dart';
import '../data/flight_data.dart';
import '../data/flight_data.dart' as flight_data;
import '../models/flight.dart';
import '../widgets/improved_date_nav_bar.dart';
import '../widgets/simple_flight_card.dart';

const Color unitedBlue = Color.fromARGB(255, 0, 77, 155);

/// Helper to convert a flight type string (case-insensitive)
/// to the corresponding FlightType enum.
FlightType parseFlightType(String flightTypeString) {
  final normalized = flightTypeString.toLowerCase();
  if (normalized == 'domestic') {
    return FlightType.Domestic;
  } else if (normalized == 'international') {
    return FlightType.International;
  } else {
    // default to Domestic if unknown
    return FlightType.Domestic;
  }
}

class FlightListScreen extends StatefulWidget {
  final String origin;
  final String flightType;
  final String destination;
  final DateTime departureDate;
  final String stops;
  final String tripType;
  final String travelAdvisories;
  final List<Map<String, dynamic>> employeeNotes;
  final String currentEmployeeId;
  final bool filterOpenSeats;

  const FlightListScreen({
    super.key,
    required this.origin,
    required this.flightType,
    required this.destination,
    required this.departureDate,
    required this.stops,
    required this.tripType,
    required this.travelAdvisories,
    required this.employeeNotes,
    required this.currentEmployeeId,
    this.filterOpenSeats = false,
  });

  @override
  _FlightListScreenState createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  late DateTime _selectedDate;
  String _selectedSortOption = 'Selected Time';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.departureDate;
    print('Initial selected date: $_selectedDate');
  }

  List<Flight> get availableFlights {
    // Combine all flights from the fake database.
    List<Flight> allFlights =
        flight_data.fakeFlights.values.expand((list) => list).toList();

    // Filter by open seats if the flag is enabled.
    if (widget.filterOpenSeats) {
      allFlights =
          allFlights.where((flight) => flight.availableSeats > 0).toList();
    }

    // Filter by the selected departure date (ignoring time).
    allFlights = allFlights
        .where((flight) =>
            flight.departureTime.year == _selectedDate.year &&
            flight.departureTime.month == _selectedDate.month &&
            flight.departureTime.day == _selectedDate.day)
        .toList();

    return allFlights;
  }

  /// Checks if there is at least one flight available on the given date.
  bool _hasFlightOnDate(DateTime date) {
    // Compare only the year, month, and day.
    return availableFlights.any((flight) =>
        flight.departureTime.year == date.year &&
        flight.departureTime.month == date.month &&
        flight.departureTime.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    // Filter the flights for the currently selected date.
    List<Flight> flightsForSelectedDate = availableFlights
        .where((flight) =>
            flight.departureTime.year == _selectedDate.year &&
            flight.departureTime.month == _selectedDate.month &&
            flight.departureTime.day == _selectedDate.day)
        .toList();

    // Sort flights based on the selected sort option.
    if (_selectedSortOption == 'Selected Time') {
      flightsForSelectedDate
          .sort((a, b) => a.departureTime.compareTo(b.departureTime));
    } else if (_selectedSortOption == 'Availability') {
      flightsForSelectedDate
          .sort((b, a) => a.availableSeats.compareTo(b.availableSeats));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: unitedBlue,
        elevation: 4,
        toolbarHeight: 50,
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
                  'Flight List',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
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
      body: SafeArea(
        child: Background(
          child: Column(
            children: [
              // Improved Date Navigation Bar.
              ImprovedDateNavBar(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                    print('New selected date: $_selectedDate');
                  });
                },
                hasFlightOnDate: _hasFlightOnDate,
              ),
              // Filter row.
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Sort by: ',
                      style: GoogleFonts.inter(),
                    ),
                    const SizedBox(width: 8.0),
                    DropdownButton<String>(
                      value: _selectedSortOption,
                      items: [
                        DropdownMenuItem(
                          value: 'Selected Time',
                          child: Text(
                            'Selected Time',
                            style: GoogleFonts.inter(),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Availability',
                          child: Text(
                            'Availability',
                            style: GoogleFonts.inter(),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSortOption = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Banner showing filtering status (if filtering only available flights)
              if (widget.filterOpenSeats)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: unitedBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Filtering only available flights',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // List of simplified flight cards.
              Expanded(
                child: flightsForSelectedDate.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: flightsForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final flight = flightsForSelectedDate[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SimpleFlightCard(
                              flight: flight,
                              onDetailsPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FlightDetailScreen(
                                      flight: flight,
                                      currentEmployeeId:
                                          widget.currentEmployeeId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No flights available for this selection.',
                          style: GoogleFonts.inter(
                            color: const Color.fromARGB(255, 23, 0, 65),
                            fontSize: 16,
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
