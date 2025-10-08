import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../models/flight.dart';
import '../data/flight_data.dart' as flight_data;
import '../screens/flight_detail_screen.dart';

class UpcomingFlightsWidget extends StatefulWidget {
  final String currentEmployeeId;
  const UpcomingFlightsWidget({super.key, required this.currentEmployeeId});

  @override
  UpcomingFlightsWidgetState createState() => UpcomingFlightsWidgetState();
}

class UpcomingFlightsWidgetState extends State<UpcomingFlightsWidget> {
  List<Flight> allFlights = [];
  List<Flight> upcomingFlights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    allFlights = flight_data.fakeFlights.values.expand((list) => list).toList();
    _filterUpcomingFlights();
    setState(() {
      _isLoading = false;
    });
  }

  void _filterUpcomingFlights() {
    upcomingFlights = allFlights.where((flight) {
      bool isUpcoming = flight.departureTime.isAfter(DateTime.now());
      bool isBooked = flight.confirmedPassengers.values
          .any((list) => list.contains(widget.currentEmployeeId));
      return isUpcoming && isBooked;
    }).toList();
  }

  // Public method to refresh the flights data.
  Future<void> refreshFlights() async {
    setState(() {
      _isLoading = true;
    });
    await _loadFlights();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: Image.asset('assets/images/loading.gif'));
    }
    if (upcomingFlights.isEmpty) {
      return Center(
          child:
              Text('No upcoming flights booked.', style: GoogleFonts.inter()));
    }
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: upcomingFlights.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final flight = upcomingFlights[index];
          return RealFlightCard(
            flight: flight,
            currentEmployeeId: widget.currentEmployeeId,
          );
        },
      ),
    );
  }
}

class RealFlightCard extends StatefulWidget {
  final Flight flight;
  final String currentEmployeeId;
  const RealFlightCard(
      {super.key, required this.flight, required this.currentEmployeeId});

  @override
  State<RealFlightCard> createState() => _RealFlightCardState();
}

class _RealFlightCardState extends State<RealFlightCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();

    // Scale animation for tap effects.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Animation controller for the airplane icon moving horizontally.
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) async {
    _controller.forward();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FlightDetailScreen(
        flight: widget.flight,
        currentEmployeeId: widget.currentEmployeeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final departureHour = flight.departureTime.hour.toString().padLeft(2, '0');
    final departureMinute =
        flight.departureTime.minute.toString().padLeft(2, '0');
    final formattedTime = "$departureHour:$departureMinute";

    // New sizes for a smaller card
    final double cardWidth = 200;
    final double cardPadding = 8;
    final double fontSizeAirportCode = 16;
    final double iconSizeMain = 28;
    final double containerHeight = iconSizeMain + 16;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF005DAA), Color(0xFF023D7C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with flight number and info icon.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Flight ${flight.flightNumber}',
                      style: GoogleFonts.inter(
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.info_outline,
                        color: Colors.white, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                // Main content with departure and arrival info and center animated section.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Origin
                    Column(
                      children: [
                        Text(
                          flight.originAirportCode,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeAirportCode,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Icon(Icons.flight_takeoff,
                            size: 14, color: Colors.white70),
                      ],
                    ),
                    // Center: Curved dashed line with animated airplane icon.
                    Expanded(
                      child: SizedBox(
                        height: containerHeight,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double availableWidth = constraints.maxWidth;
                            final double centerY = containerHeight / 2;
                            return Stack(
                              children: [
                                // Curved dashed line.
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: CustomPaint(
                                    painter: DashedLinePainter(
                                      color: Colors.white70,
                                      dashWidth: 6,
                                      dashSpace: 4,
                                      strokeWidth: 1,
                                      curvature: 20,
                                    ),
                                  ),
                                ),
                                // Animated airplane icon moving along the Bézier curve.
                                AnimatedBuilder(
                                  animation: _floatingController,
                                  builder: (context, child) {
                                    double t = _floatingController.value;
                                    double curvature = 20.0;
                                    final double planeYOffset = 5;
                                    double curveX = availableWidth * t;
                                    double curveY =
                                        centerY - 2 * curvature * t * (1 - t);
                                    double adjustedX =
                                        curveX - iconSizeMain / 2;
                                    double adjustedY = curveY -
                                        iconSizeMain / 2 -
                                        planeYOffset;
                                    double dx = availableWidth;
                                    double dy = 2 * curvature * (2 * t - 1);
                                    double angle =
                                        math.atan2(dy, dx) + math.pi / 2;
                                    return Positioned(
                                      left: adjustedX,
                                      top: adjustedY,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Transform.rotate(
                                          alignment: Alignment.center,
                                          angle: angle,
                                          child: Icon(
                                            Icons.airplanemode_active,
                                            color: Colors.white70,
                                            size: iconSizeMain,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    // Destination
                    Column(
                      children: [
                        Text(
                          flight.destinationAirportCode,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeAirportCode,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Icon(Icons.flight_land,
                            size: 14, color: Colors.white70),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Footer with schedule, gate, and calendar details.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 2),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.room, size: 16, color: Colors.white70),
                        const SizedBox(width: 2),
                        const Text(
                          'Gate TBD',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 2),
                        Text(
                          '${flight.departureTime.day}/${flight.departureTime.month}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw a curved dashed line along a quadratic Bézier curve.
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;
  final double curvature; // controls the magnitude of the upward curve

  DashedLinePainter({
    required this.color,
    this.dashWidth = 6, // longer dashes for a less dashed look
    this.dashSpace = 4,
    this.strokeWidth = 1,
    this.curvature = 20, // adjust to change how pronounced the upward curve is
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Create an upward-curving path using a quadratic Bézier curve.
    // Start at the left center, curve upward, then end at the right center.
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2 -
          curvature, // subtracting curvature curves the line upward
      size.width,
      size.height / 2,
    );

    // Draw the dashes along the curved path.
    final Iterable<PathMetric> metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = distance + dashWidth;
        final Path dashPath = metric.extractPath(distance, end);
        canvas.drawPath(dashPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
