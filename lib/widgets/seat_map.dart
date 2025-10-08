import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flight.dart';
import '../core/app_theme.dart';


class RealisticCabinSeatMap extends StatelessWidget {
  final String cabin;
  final int seatCount;
  final Map<String, String> assignments;
  final String? bookedSeat;
  final List<String> connectingPassengerIds;
  final int startingRow;
  final bool isFirstCabin;
  final bool isLastCabin;

  const RealisticCabinSeatMap({
    super.key,
    required this.cabin,
    required this.seatCount,
    required this.assignments,
    this.bookedSeat,
    required this.connectingPassengerIds,
    required this.startingRow,
    required this.isFirstCabin,
    required this.isLastCabin,
  });

  @override
  Widget build(BuildContext context) {
    final layout = getCabinSeatLayout(cabin, seatCount, startingRow);
    final Map<String, String> inverseAssignments =
        assignments.map((k, v) => MapEntry(v, k));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isFirstCabin) ...[
          Row(
            children: const [
              SizedBox(width: 38),
              Expanded(child: AirplaneNose()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.wc, color: Colors.black54),
              Icon(Icons.exit_to_app, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.airline_seat_recline_normal,
                size: 20, color: Colors.black54),
            const SizedBox(width: 4),
            Text(
              cabin,
              style: GoogleFonts.inter(
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: layout.map((row) {
            String rowNumber = "";
            for (var seat in row) {
              if (seat != null && seat.isNotEmpty) {
                rowNumber = seat.replaceAll(RegExp(r'[A-Z]'), '');
                break;
              }
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      alignment: Alignment.center,
                      child: Text(
                        rowNumber,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...row.map((seatLabel) {
                      if (seatLabel == null) {
                        return const SizedBox(width: 20);
                      }
                      Color seatColor;
                      if (!assignments.values.contains(seatLabel)) {
                        seatColor = availableSeatColor;
                      } else if (bookedSeat == seatLabel) {
                        seatColor = bookedSeatColor;
                      } else {
                        final passengerId = inverseAssignments[seatLabel];
                        if (passengerId != null &&
                            connectingPassengerIds.contains(passengerId)) {
                          seatColor = connectingSeatColor;
                        } else {
                          seatColor = occupiedSeatColor;
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            if (assignments.values.contains(seatLabel)) {
                              final passengerId = inverseAssignments[seatLabel];
                              if (passengerId != null) {
                                String status;
                                if (bookedSeat == seatLabel) {
                                  status = "Your Seat";
                                } else if (connectingPassengerIds
                                    .contains(passengerId)) {
                                  status = "Potential Misconnect";
                                } else {
                                  status = "Occupied";
                                }
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.event_seat,
                                                color: AppColors.primary, size: 48),
                                            const SizedBox(height: 12),
                                            Text("Passenger Info",
                                                style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.person,
                                                    color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                      "Passenger ID: $passengerId",
                                                      style:
                                                          GoogleFonts.inter()),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.info_outline,
                                                    color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text("Status: $status",
                                                      style:
                                                          GoogleFonts.inter()),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              icon: const Icon(Icons.check),
                                              label: Text("Close",
                                                  style: GoogleFonts.inter()),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                          },
                          child: SeatWidget(
                            seatLabel: seatLabel,
                            color: seatColor,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (isLastCabin) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.wc, color: Colors.black54),
              Icon(Icons.exit_to_app, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              SizedBox(width: 38),
              Expanded(child: AirplaneTail()),
            ],
          ),
        ],
      ],
    );
  }
}

const Color availableSeatColor = Color.fromARGB(255, 187, 187, 187);
const Color occupiedSeatColor = AppColors.primary;
const Color bookedSeatColor = Color.fromARGB(255, 63, 168, 253);
const Color connectingSeatColor = Color(0xFFFFC107);

class AirplaneNose extends StatelessWidget {
  const AirplaneNose({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: AirplaneNosePainter(),
        child: Container(),
      ),
    );
  }
}

class AirplaneNosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, -size.height * 0.5, size.width, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AirplaneTail extends StatelessWidget {
  const AirplaneTail({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: AirplaneTailPainter(),
        child: Container(),
      ),
    );
  }
}

class AirplaneTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height * 1.5, size.width, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SeatWidget extends StatelessWidget {
  final String seatLabel;
  final Color color;
  const SeatWidget({super.key, required this.seatLabel, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.9), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.event_seat,
              color: Colors.white.withValues(alpha: 0.8), size: 28),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                seatLabel,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}

List<List<String?>> getCabinSeatLayout(
    String cabin, int seatCount, int startingRow) {
  List<String?> rowLayout;
  if (cabin.toLowerCase() == "united first") {
    rowLayout = ["A", "B", null, "C", "D"];
  } else if (cabin.toLowerCase() == "united economy") {
    rowLayout = ["A", "B", "C", null, "D", "E", "F"];
  } else {
    rowLayout = ["A", "B", "C", null, "D", "E", "F"];
  }
  final seatsPerRow = rowLayout.where((s) => s != null).length;
  final totalRows = (seatCount / seatsPerRow).ceil();
  final layout = <List<String?>>[];
  int seatsAssigned = 0;
  for (int i = 0; i < totalRows; i++) {
    final currentRow = <String?>[];
    int rowNumber = startingRow + i;
    for (var seat in rowLayout) {
      if (seat == null) {
        currentRow.add(null);
      } else {
        if (seatsAssigned < seatCount) {
          currentRow.add('$rowNumber$seat');
          seatsAssigned++;
        } else {
          currentRow.add(null);
        }
      }
    }
    layout.add(currentRow);
  }
  return layout;
}

class SeatAssignmentResult {
  final Map<String, String> assignments;
  final int rowCount;
  SeatAssignmentResult({required this.assignments, required this.rowCount});
}

SeatAssignmentResult generateDummySeatAssignmentsForCabin(
    String cabin, int seatCount, List<String> passengerIds, int startingRow) {
  final layout = getCabinSeatLayout(cabin, seatCount, startingRow);
  final availableSeats =
      layout.expand((row) => row).whereType<String>().toList();
  final assignments = <String, String>{};
  for (int i = 0; i < passengerIds.length && i < availableSeats.length; i++) {
    assignments[passengerIds[i]] = availableSeats[i];
  }
  return SeatAssignmentResult(
      assignments: assignments, rowCount: layout.length);
}

class SeatAssignmentData {
  final Map<String, String> assignments;
  final int startingRow;
  final int rowCount;
  SeatAssignmentData(
      {required this.assignments,
      required this.startingRow,
      required this.rowCount});
}

Map<String, SeatAssignmentData> generateDummySeatAssignmentsByCabin(
    Flight flight) {
  int globalRow = 1;
  Map<String, SeatAssignmentData> dataByCabin = {};

  if (flight.confirmedPassengers.containsKey('United First')) {
    int seatCount = flight.seats['United First'] ??
        flight.confirmedPassengers['United First']!.length;
    var result = generateDummySeatAssignmentsForCabin('United First', seatCount,
        flight.confirmedPassengers['United First']!, globalRow);
    dataByCabin['United First'] = SeatAssignmentData(
        assignments: result.assignments,
        startingRow: globalRow,
        rowCount: result.rowCount);
    globalRow += result.rowCount;
  }
  if (flight.confirmedPassengers.containsKey('United Economy')) {
    int seatCount = flight.seats['United Economy'] ??
        flight.confirmedPassengers['United Economy']!.length;
    var result = generateDummySeatAssignmentsForCabin('United Economy',
        seatCount, flight.confirmedPassengers['United Economy']!, globalRow);
    dataByCabin['United Economy'] = SeatAssignmentData(
        assignments: result.assignments,
        startingRow: globalRow,
        rowCount: result.rowCount);
    globalRow += result.rowCount;
  }
  flight.confirmedPassengers.forEach((cabin, passengers) {
    if (cabin != 'United First' && cabin != 'United Economy') {
      int seatCount = flight.seats[cabin] ?? passengers.length;
      var result = generateDummySeatAssignmentsForCabin(
          cabin, seatCount, passengers, globalRow);
      dataByCabin[cabin] = SeatAssignmentData(
          assignments: result.assignments,
          startingRow: globalRow,
          rowCount: result.rowCount);
      globalRow += result.rowCount;
    }
  });
  return dataByCabin;
}

class SeatMapScreen extends StatelessWidget {
  final Flight flight;
  final String currentEmployeeId;

  const SeatMapScreen({
    super.key,
    required this.flight,
    required this.currentEmployeeId,
  });

  @override
  Widget build(BuildContext context) {
    final seatAssignments = generateDummySeatAssignmentsByCabin(flight);
    final cabinEntries = seatAssignments.entries.toList();

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
                'Seat Map',
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
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(cabinEntries.length, (index) {
            final cabin = cabinEntries[index].key;
            final data = cabinEntries[index].value;
            final seatCount = flight.seats[cabin] ?? data.assignments.length;
            final currentUserSeat = data.assignments[currentEmployeeId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RealisticCabinSeatMap(
                cabin: cabin,
                seatCount: seatCount,
                assignments: data.assignments,
                bookedSeat: currentUserSeat,
                connectingPassengerIds: flight.connectingPassengerIds ?? [],
                startingRow: data.startingRow,
                isFirstCabin: index == 0,
                isLastCabin: index == cabinEntries.length - 1,
              ),
            );
          }),
        ),
      ),
    );
  }
}
