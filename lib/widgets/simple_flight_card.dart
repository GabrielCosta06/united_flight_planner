import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/flight.dart';
import '../data/flight_data.dart';

const Color unitedBlue = Color.fromARGB(255, 0, 77, 155);

List<String> getCabinClasses(Flight flight) {
  if (flight.aircraft.contains("777-200")) {
    return ['United Polaris', 'United Premium Plus', 'United Economy'];
  } else if (flight.aircraft.contains("737-900")) {
    return ['United First', 'United Economy'];
  } else {
    return ['United First', 'United Economy Plus', 'United Economy'];
  }
}

class SimpleFlightCard extends StatefulWidget {
  final Flight flight;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onSelectPressed;

  const SimpleFlightCard({
    super.key,
    required this.flight,
    this.onDetailsPressed,
    this.onSelectPressed,
  });

  @override
  _SimpleFlightCardState createState() => _SimpleFlightCardState();
}

class _SimpleFlightCardState extends State<SimpleFlightCard> {
  bool _isSelected = false;

  Color _getTotalSeatsColor(int seats) {
    if (seats <= 10) return Colors.red;
    if (seats <= 50) return Colors.orange;
    return Colors.green;
  }

  Map<String, int> _getCabinAvailableSeats(Flight f) {
    final cabinClasses = getCabinClasses(f);
    final available = <String, int>{};
    for (var cabin in cabinClasses) {
      final total = f.seats[cabin] ?? 0;
      final confirmed = f.confirmedPassengers[cabin]?.length ?? 0;
      available[cabin] = total - confirmed;
    }
    return available;
  }

  void _toggleSelection() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final originCode = airportCodes[flight.origin] ?? flight.origin;
    final destinationCode =
        airportCodes[flight.destination] ?? flight.destination;
    final departureTime = flight.departureTime;
    final arrivalTime = flight.arrivalTime;
    final flightNumber = flight.flightNumber;
    final aircraft = flight.aircraft;
    final totalSeats = flight.availableSeats;
    final cabinAvailableSeats = _getCabinAvailableSeats(flight);
    final totalNonRevs = flight.standbyPassengers.entries.fold<int>(
      0,
      (acc, entry) => acc + entry.value.length,
    );

    final List<Widget> breakdownWidgets =
        cabinAvailableSeats.entries.map((entry) {
      final abbreviatedCabin = entry.key.startsWith("United ")
          ? entry.key.substring("United ".length)
          : entry.key;
      return RichText(
        text: TextSpan(
          style: GoogleFonts.inter(color: Colors.black),
          children: [
            TextSpan(
                text: '${entry.value} ',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            TextSpan(
                text: abbreviatedCabin.toLowerCase(),
                style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
      );
    }).toList();

    if (totalNonRevs > 0) {
      breakdownWidgets.add(
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(color: Colors.black),
            children: [
              TextSpan(
                  text: '$totalNonRevs ',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              TextSpan(
                text: 'non-revs',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleSelection,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: _isSelected ? unitedBlue : Colors.grey.shade300,
            width: _isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$originCode → $destinationCode',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat.jm().format(departureTime)} → ${DateFormat.jm().format(arrivalTime)}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          aircraft,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(Icons.flight_takeoff,
                          color: unitedBlue, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        flightNumber,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getTotalSeatsColor(totalSeats),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$totalSeats',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'available seats',
                        style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Wrap(
                        spacing: 8, runSpacing: 4, children: breakdownWidgets),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: unitedBlue,
                      side: BorderSide(color: unitedBlue),
                    ),
                    onPressed: widget.onDetailsPressed ?? () {},
                    child: Text('Details', style: GoogleFonts.inter()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: unitedBlue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _toggleSelection();
                      if (widget.onSelectPressed != null) {
                        widget.onSelectPressed!();
                      }
                    },
                    child: Text('Select',
                        style: GoogleFonts.inter(color: Colors.white)),
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
