import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../models/flight.dart';
import '../widgets/background.dart';
import '../widgets/improved_date_nav_bar.dart';
import '../widgets/simple_flight_card.dart';
import '../data/flight_data.dart' as flight_data;
import 'flight_detail_screen.dart';

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
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  late DateTime _selectedDate;
  late final flight_data.FlightType _flightType;
  late final String _flightKey;
  String _selectedSortOption = 'Selected Time';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.departureDate;
    _flightType = flight_data.parseFlightType(widget.flightType);
    _flightKey = flight_data.generateFlightKey(
      widget.origin,
      widget.destination,
      _flightType,
    );
    debugPrint('Flight search key: $_flightKey');
    debugPrint('Initial selected date: $_selectedDate');
  }

  /// Flights matching the chosen origin/destination/flight type.
  List<Flight> get _routeFlights {
    Iterable<Flight> flights;

    if (widget.origin.isEmpty || widget.destination.isEmpty) {
      flights = flight_data.fakeFlights.values.expand((list) => list).where(
        (flight) {
          final originMatches =
              widget.origin.isEmpty || flight.origin == widget.origin;
          final destinationMatches = widget.destination.isEmpty ||
              flight.destination == widget.destination;
          return originMatches && destinationMatches;
        },
      );
    } else {
      flights = flight_data.fakeFlights[_flightKey] ?? const [];
      if (flights.isEmpty) {
        debugPrint('No flights found for $_flightKey');
      }
    }

    return flights.where(_matchesStops).toList();
  }

  bool _matchesStops(Flight flight) {
    final requested = widget.stops.toLowerCase().trim();
    final stops = flight.stops.toLowerCase();
    switch (requested) {
      case 'nonstop':
        return stops.contains('nonstop');
      case '1 stop':
        return stops.contains('1 stop');
      case '2 stops':
        return stops.contains('2 stop');
      case '3+ stops':
        return !stops.contains('nonstop') &&
            !stops.contains('1 stop') &&
            !stops.contains('2 stop');
      default:
        return true;
    }
  }

  List<Flight> _flightsForDate(DateTime date,
      {bool ignoreSeatFilter = false}) {
    final flights = _routeFlights.where((flight) {
      final departure = flight.departureTime;
      return departure.year == date.year &&
          departure.month == date.month &&
          departure.day == date.day;
    }).toList();

    if (widget.filterOpenSeats && !ignoreSeatFilter) {
      flights.retainWhere((flight) => flight.availableSeats > 0);
    }

    return flights;
  }

  List<Flight> get availableFlights => _flightsForDate(_selectedDate);

  /// Checks if there is at least one flight available on the given date.
  bool _hasFlightOnDate(DateTime date) => _flightsForDate(date).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Filter the flights for the currently selected date.
    final String originLabel =
        widget.origin.isEmpty ? 'All origins' : widget.origin;
    final String destinationLabel =
        widget.destination.isEmpty ? 'All destinations' : widget.destination;
    final String routeSummary = '$originLabel → $destinationLabel';
    final String detailSummary =
        '${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)} | ${widget.stops} | ${widget.tripType} | ${widget.flightType}';
    final List<Flight> flightsForSelectedDate =
        List<Flight>.from(availableFlights);
    final bool hasFlightsForRoute = _routeFlights.isNotEmpty;
    final bool hasFlightsForDate = flightsForSelectedDate.isNotEmpty;
    final bool removedBySeatFilter = widget.filterOpenSeats &&
        !hasFlightsForDate &&
        _flightsForDate(_selectedDate, ignoreSeatFilter: true).isNotEmpty;


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
        backgroundColor: AppColors.primary,
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
          child: Column(
            children: [
              // Improved Date Navigation Bar.
              ImprovedDateNavBar(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                    debugPrint('New selected date: $_selectedDate');
                  });
                },
                hasFlightOnDate: _hasFlightOnDate,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.flight_takeoff,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      routeSummary,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      detailSummary,
                      style: GoogleFonts.inter(
                        color: Colors.blueGrey[600],
                      ),
                    ),
                  ),
                ),
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
              if (widget.travelAdvisories.trim().isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Card(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.info, color: AppColors.primary),
                      title: Text(
                        'Travel advisory',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        widget.travelAdvisories.trim(),
                        style: GoogleFonts.inter(),
                      ),
                    ),
                  ),
                ),
              if (widget.employeeNotes.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crew notes',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...widget.employeeNotes.take(3).map((note) {
                            final noteText =
                                (note['note'] as String?)?.trim() ?? '';
                            if (noteText.isEmpty) return const SizedBox.shrink();
                            final author =
                                (note['employee'] as String?)?.trim() ??
                                    'Crew member';
                            final rawDate = note['date'] as String?;
                            String dateLabel = '';
                            if (rawDate != null) {
                              try {
                                dateLabel =
                                    DateFormat('MMM d').format(DateTime.parse(rawDate));
                              } catch (_) {
                                dateLabel = '';
                              }
                            }
                            final meta = dateLabel.isNotEmpty
                                ? '$author - $dateLabel'
                                : author;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '$noteText\n- $meta',
                                      style: GoogleFonts.inter(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
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
                      color: AppColors.primary,
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
                          !hasFlightsForRoute
                              ? 'No scheduled flights for this route yet.'
                              : removedBySeatFilter
                                  ? 'No flights with open seats for this date.'
                                  : 'No flights match your filters for this date.',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryDark,
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
