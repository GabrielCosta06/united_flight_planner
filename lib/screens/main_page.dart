import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../widgets/background.dart';
import '../widgets/upcoming_flights_card.dart';
import 'flight_status_screen.dart';
import 'origin_screen.dart';
import 'account_screen.dart';
import 'trips_screen.dart';
import '../data/flight_data.dart';
import '../data/employee_data.dart';
import '../models/flight.dart';

// Global key for the DashboardScreen state (if needed).
final GlobalKey<DashboardScreenState> dashboardKey =
    GlobalKey<DashboardScreenState>();

/// Arguments required to launch the [MainPage] via named routes.
class MainPageArguments {
  final String currentEmployeeId;

  const MainPageArguments(this.currentEmployeeId);
}

class MainPage extends StatefulWidget {
  static const String routeName = '/main';

  final String currentEmployeeId;
  const MainPage({super.key, required this.currentEmployeeId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List.generate(5, (index) => GlobalKey<NavigatorState>());

  // Create a GlobalKey for the UpcomingFlightsWidget state.
  final GlobalKey<UpcomingFlightsWidgetState> upcomingFlightsKey =
      GlobalKey<UpcomingFlightsWidgetState>();

  late final AnimationController _navSlideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _navSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _navSlideController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _navSlideController.dispose();
    super.dispose();
  }

  void _onBottomNavItemTapped(int index) {
    if (index == 0) {
      if (_selectedIndex != 0) {
        _animateNavSlide(index);
        setState(() => _selectedIndex = 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          upcomingFlightsKey.currentState?.refreshFlights();
        });
      } else {
        upcomingFlightsKey.currentState?.refreshFlights();
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      }
    } else {
      _animateNavSlide(index);
      setState(() => _selectedIndex = index);
    }
  }

  void _animateNavSlide(int newIndex) {
    _slideAnimation = Tween<double>(
      begin: _previousIndex.toDouble(),
      end: newIndex.toDouble(),
    ).animate(
      CurvedAnimation(parent: _navSlideController, curve: Curves.easeInOut),
    );
    _previousIndex = newIndex;
    _navSlideController.forward(from: 0);
  }

  Widget _buildAnimatedBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Stack(
            children: [
              // Sliding indicator
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, _) {
                  final containerWidth = MediaQuery.of(context).size.width - 16; // Account for padding
                  final itemWidth = containerWidth / 5;
                  return Positioned(
                    left: 8 + (_slideAnimation.value * itemWidth),
                    top: 4,
                    bottom: 4,
                    width: itemWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.primaryLight.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Nav items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
              final isSelected = _selectedIndex == index;
              final items = [
                {'icon': Icons.home, 'label': 'Home'},
                {'icon': Icons.search, 'label': 'Search'},
                {'icon': Icons.map, 'label': 'Trips'},
                {'icon': Icons.local_airport, 'label': 'Status'},
                {'icon': Icons.person, 'label': 'Account'},
              ];
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onBottomNavItemTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[index]['icon'] as IconData,
                          color: isSelected ? AppColors.primary : Colors.grey.shade600,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index]['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (index) {
            case 0:
              builder = (context) => DashboardScreen(
                    key: dashboardKey,
                    employeeId: widget.currentEmployeeId,
                    upcomingFlightsKey: upcomingFlightsKey,
                  );
              break;
            case 1:
              builder = (context) =>
                  OriginScreen(currentEmployeeId: widget.currentEmployeeId);
              break;
            case 2:
              builder = (context) =>
                  TripsScreen(currentEmployeeId: widget.currentEmployeeId);
              break;
            case 3:
              builder = (context) =>
                  FlightStatusScreen(currentEmployeeId: widget.currentEmployeeId);
              break;
            case 4:
              builder = (context) =>
                  AccountScreen(currentEmployeeId: widget.currentEmployeeId);
              break;
            default:
              builder =
                  (context) => const Center(child: Text('Page not found'));
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Stack(
          children: List.generate(5, (index) => _buildOffstageNavigator(index)),
        ),
      ),
      bottomNavigationBar: _buildAnimatedBottomNav(),
    );
  }

}

class _SheenPainter extends CustomPainter {
  final double progress; // 0..1
  _SheenPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Create a subtle diagonal moving sheen band
    final double bandWidth = size.width * 0.3;
    final double diagonal = size.width + size.height;
    final double offset = (progress * (diagonal + bandWidth)) - bandWidth;

    // Only paint when the band is actually visible (middle portion of animation)
    if (progress < 0.2 || progress > 0.8) return;

    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(offset - bandWidth / 2, 0, bandWidth, size.height));

    canvas.save();
    canvas.translate(offset, size.height * 0.5);
    canvas.rotate(0.5); // ~28 degrees
    canvas.drawRect(
      Rect.fromLTWH(-bandWidth / 2, -size.height, bandWidth, size.height * 2),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SheenPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _HeaderShimmerPainter extends CustomPainter {
  final double progress;
  _HeaderShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double shimmerWidth = size.width * 0.4;
    final double offset = (progress * (size.width + shimmerWidth)) - shimmerWidth;

    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(offset, 0, shimmerWidth, size.height));

    canvas.drawRect(
      Rect.fromLTWH(offset, 0, shimmerWidth, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeaderShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class DashboardScreen extends StatefulWidget {
  final String employeeId;
  final GlobalKey<UpcomingFlightsWidgetState> upcomingFlightsKey;
  const DashboardScreen({
    super.key,
    required this.employeeId,
    required this.upcomingFlightsKey,
  });

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  // Animated pill badge for "standby segments saved"
  Widget _buildSavedSegmentsBadge(int count) {
    return AnimatedBuilder(
      animation: _loopController,
      builder: (context, _) {
        final t = _loopController.value;
        final shimmerAlpha = 0.15 + 0.10 * math.sin(2 * math.pi * t);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.85),
                AppColors.primaryLight.withValues(alpha: 0.85),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8 * shimmerAlpha),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count standby segments saved',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Animated sheen overlay for the hero card
  Widget _buildHeroSheen() {
    return AnimatedBuilder(
      animation: _loopController,
      builder: (context, _) {
        final t = _loopController.value;
        return CustomPaint(
          painter: _SheenPainter(progress: t),
          size: Size.infinite,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final employee = employees.firstWhere(
      (emp) => emp.username == widget.employeeId,
      orElse: () => Employee(
        employeeId: widget.employeeId,
        name: widget.employeeId,
        username: widget.employeeId,
        email: '',
        password: '',
        abbreviatedName: '',
        abbreviatedName2: widget.employeeId,
        profileImagePath: '',
        passType: '',
      ),
    );

    final List<Flight> allFlights =
        fakeFlights.values.expand((list) => list).toList();
    final List<Flight> upcomingFlights = allFlights.where((flight) {
      final bool isUpcoming = flight.departureTime.isAfter(DateTime.now());
      final bool isBooked = flight.confirmedPassengers.values
          .any((list) => list.contains(widget.employeeId));
      return isUpcoming && isBooked;
    }).toList();

    final List<Flight> sortedUpcoming =
        List<Flight>.from(upcomingFlights)
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
    final Flight? nextFlight =
        sortedUpcoming.isNotEmpty ? sortedUpcoming.first : null;
    final int upcomingCount = upcomingFlights.length;
    final int openSeatsToday = allFlights
        .where((flight) =>
            flight.availableSeats > 0 &&
            _isSameDay(flight.departureTime, DateTime.now()))
        .length;
    final int standbyPassengers = allFlights.fold<int>(
        0, (total, flight) => total + flight.standbyCount);
    final Flight? busiestFlight = allFlights.isNotEmpty
        ? allFlights.reduce(
            (a, b) => a.standbyCount >= b.standbyCount ? a : b,
          )
        : null;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: true,
          expandedHeight: 120,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive sizes
              final isCollapsed = constraints.biggest.height <= kToolbarHeight + MediaQuery.of(context).padding.top + 20;
              final screenWidth = MediaQuery.of(context).size.width;
              final isNarrow = screenWidth < 380;
              
              return FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Main gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // Bottom gradient fade for depth
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Animated shimmer overlay
                    AnimatedBuilder(
                      animation: _loopController,
                      builder: (context, _) {
                        return Positioned.fill(
                          child: CustomPaint(
                            painter: _HeaderShimmerPainter(
                              progress: _loopController.value,
                            ),
                          ),
                        );
                      },
                    ),
                    // Content on top of background
                    SafeArea(
                      child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 12 : 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Elevated profile avatar with glow
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: isNarrow ? 22 : 26,
                              backgroundColor: Colors.white,
                              child: Text(
                                _initials(employee),
                                style: GoogleFonts.inter(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isNarrow ? 14 : 18,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isNarrow ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_greeting()}, ${_firstName(employee)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: isNarrow ? 16 : 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                if (!isCollapsed) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.verified_user,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        size: isNarrow ? 12 : 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Verified • ${employee.employeeId}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: isNarrow ? 11 : 12,
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isNarrow ? 6 : 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'EMPLOYEE',
                                      style: GoogleFonts.inter(
                                        fontSize: isNarrow ? 8 : 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Animated refresh button
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 1.0 + (0.08 * (0.5 - (value - 0.5).abs()) * 2),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15 + (0.05 * value)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.refresh_rounded),
                                    tooltip: 'Refresh flights',
                                    color: Colors.white,
                                    iconSize: isNarrow ? 20 : 24,
                                    padding: EdgeInsets.all(isNarrow ? 8 : 12),
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      widget.upcomingFlightsKey.currentState?.refreshFlights();
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _animatedSection(
              delayMs: 0,
              child: AnimatedBuilder(
                animation: _loopController,
                builder: (context, child) {
                  final float = math.sin(2 * math.pi * _loopController.value * 0.5) * 3;
                  return Transform.translate(
                    offset: Offset(0, float),
                    child: child,
                  );
                },
                child: _buildHeroCard(
                  context,
                  employee,
                  nextFlight,
                  upcomingCount,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _animatedSection(
              delayMs: 100,
              child: _buildQuickStatsRow(
                upcomingCount,
                standbyPassengers,
                openSeatsToday,
              ),
            ),
            const SizedBox(height: 28),
            _animatedSection(
              delayMs: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle(
                    'Upcoming flights',
                    caption: 'Track your standby opportunities at a glance',
                    icon: Icons.flight_takeoff,
                  ),
                  const SizedBox(height: 12),
                  UpcomingFlightsWidget(
                    key: widget.upcomingFlightsKey,
                    currentEmployeeId: widget.employeeId,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _animatedSection(
              delayMs: 300,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 640;
                  if (isNarrow) {
                    return Column(
                      children: [
                        _buildOperationalCard(
                          context: context,
                          standbyPassengers: standbyPassengers,
                          openSeatsToday: openSeatsToday,
                          busiestFlight: busiestFlight,
                        ),
                        const SizedBox(height: 16),
                        _buildCommunityCard(context),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: _buildOperationalCard(
                          context: context,
                          standbyPassengers: standbyPassengers,
                          openSeatsToday: openSeatsToday,
                          busiestFlight: busiestFlight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCommunityCard(context)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            _animatedSection(
              delayMs: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Quick actions', icon: Icons.bolt),
                  const SizedBox(height: 12),
                  _buildQuickActionBar(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    Employee employee,
  Flight? nextFlight,
    int upcomingCount,
  ) {
    final bool hasUpcoming = nextFlight != null;
    final String routeLabel = hasUpcoming
        ? '${nextFlight.originAirportCode} → ${nextFlight.destinationAirportCode}'
        : 'Choose a route to get live seat updates';
    final String timingLabel = hasUpcoming
        ? DateFormat('EEE, MMM d at h:mm a').format(nextFlight.departureTime)
        : 'See seat forecasts across the network';
    final String seatLabel = hasUpcoming
        ? '${nextFlight.availableSeats} open seats, ${nextFlight.standbyCount} on standby'
        : 'Standby availability refreshes\nevery few minutes';

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryVibrant,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasUpcoming
                ? 'Your next standby chance'
                : 'Welcome back, ${_firstName(employee)}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            routeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  timingLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.event_seat,
                  color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  seatLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (hasUpcoming) ...[
            AnimatedBuilder(
              animation: _loopController,
              builder: (context, child) {
                final pulse = 0.5 + 0.5 * math.sin(2 * math.pi * _loopController.value * 0.7);
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPulsingChip(
                      icon: Icons.event_seat,
                      label: '${nextFlight.availableSeats} open seats',
                      pulse: pulse,
                    ),
                    _buildPulsingChip(
                      icon: Icons.groups,
                      label: '${nextFlight.standbyCount} standby',
                      pulse: pulse * 0.8,
                    ),
                    if (nextFlight.wifi)
                      _buildPulsingChip(
                        icon: Icons.wifi,
                        label: 'Wi‑Fi',
                        pulse: pulse * 0.6,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.list_alt, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TripsScreen(currentEmployeeId: widget.employeeId),
                    ),
                  );
                },
                label: Text(
                  hasUpcoming ? 'View standby list' : 'Explore standby routes',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          OriginScreen(currentEmployeeId: widget.employeeId),
                    ),
                  );
                },
                label: Text(
                  'Plan new trip',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildSavedSegmentsBadge(upcomingCount),
            ],
          ),
        ],
      ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: IgnorePointer(
              child: _buildHeroSheen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(
    int upcomingCount,
    int standbyPassengers,
    int openSeatsToday,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;
        if (isNarrow) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: _buildStatCard(
                  icon: Icons.flight_takeoff,
                  label: 'Saved standby',
                  value: upcomingCount.toString(),
                  caption: 'Segments in your list',
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: _buildStatCard(
                  icon: Icons.people_alt,
                  label: 'Standby queue',
                  value: standbyPassengers.toString(),
                  caption: 'Travelers across today\'s flights',
                ),
              ),
              SizedBox(
                width: constraints.maxWidth,
                child: _buildStatCard(
                  icon: Icons.event_available,
                  label: 'Open departures',
                  value: openSeatsToday.toString(),
                  caption: 'Flights with open seats today',
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.flight_takeoff,
                label: 'Saved standby',
                value: upcomingCount.toString(),
                caption: 'Segments in your list',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_alt,
                label: 'Standby queue',
                value: standbyPassengers.toString(),
                caption: 'Travelers across today\'s flights',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.event_available,
                label: 'Open departures',
                value: openSeatsToday.toString(),
                caption: 'Flights with open seats today',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    String? caption,
  }) {
    return AnimatedBuilder(
      animation: _loopController,
      builder: (context, child) {
        final pulse = 0.5 + 0.5 * math.sin(2 * math.pi * _loopController.value * 0.3 + icon.hashCode % 100);
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return MouseRegion(
              onEnter: (_) {},
              onExit: (_) {},
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08 + (0.02 * pulse)),
                  AppColors.primaryLight.withValues(alpha: 0.04 + (0.01 * pulse)),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12 + (0.03 * pulse)),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04 + (0.02 * pulse)),
                  blurRadius: 8 + (4 * pulse),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 4),
              Text(
                caption,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {String? caption, IconData? icon}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: Row(
              children: [
                if (icon != null) ...[
                  AnimatedBuilder(
                    animation: _loopController,
                    builder: (context, _) {
                      final double pulse = 0.5 + 0.5 * math.sin(2 * math.pi * _loopController.value);
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryVibrant,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15 + 0.15 * pulse),
                              blurRadius: 6 + 6 * pulse,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (caption != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          caption,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOperationalCard({
    required BuildContext context,
    required int standbyPassengers,
    required int openSeatsToday,
    required Flight? busiestFlight,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard_customize, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Operational snapshot',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOperationalRow(
              context: context,
              icon: Icons.airlines,
              label: '$openSeatsToday flights with open cabins today',
              color: Colors.teal,
            ),
            const SizedBox(height: 12),
            _buildOperationalRow(
              context: context,
              icon: Icons.groups,
              label: '$standbyPassengers travelers waiting across the network',
              color: Colors.orange,
            ),
            if (busiestFlight != null) ...[
              const SizedBox(height: 12),
              _buildOperationalRow(
                context: context,
                icon: Icons.local_fire_department,
                label:
                    'Busiest route: ${busiestFlight.originAirportCode} → ${busiestFlight.destinationAirportCode} — ${busiestFlight.standbyCount} standby',
                color: Colors.redAccent,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Status refreshes every five minutes to keep you ahead of the curve.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCard(BuildContext context) {
    const highlights = [
      'Flight benefits refresher: priority cutover next Monday.',
      'Crew tip: ORD security is quieter via Terminal 1 center bridge.',
      'Share your travel wins in the employee forum today.',
    ];

    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sentiment_satisfied_alt, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Community highlights',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final item in highlights) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        TripsScreen(currentEmployeeId: widget.employeeId),
                  ),
                );
              },
              child: Text(
                'Browse all updates',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBar(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine columns responsively
            final double maxW = constraints.maxWidth;
            final int columns = maxW < 480
                ? 1
                : (maxW < 760
                    ? 2
                    : 3);
            const double spacing = 12;
            final double tileWidth = (maxW - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.search,
                    title: 'Search flights',
                    caption: 'Find routes and forecast seats',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              OriginScreen(currentEmployeeId: widget.employeeId),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.list_alt,
                    title: 'View trips',
                    caption: 'Your saved standby segments',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TripsScreen(currentEmployeeId: widget.employeeId),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.person,
                    title: 'My profile',
                    caption: 'Account and preferences',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AccountScreen(currentEmployeeId: widget.employeeId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? caption,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppColors.primaryLight.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.arrow_forward, color: AppColors.primary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(Employee employee) {
    final source = employee.abbreviatedName2.isNotEmpty
        ? employee.abbreviatedName2
        : employee.name;
    final parts = source.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : employee.username;
  }

  String _initials(Employee employee) {
    final source = employee.abbreviatedName2.isNotEmpty
        ? employee.abbreviatedName2
        : employee.name;
    final parts = source.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts.isNotEmpty
        ? parts.first[0].toUpperCase()
        : employee.username.isNotEmpty
            ? employee.username[0].toUpperCase()
            : 'U';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Pulsing chip widget for hero card
  Widget _buildPulsingChip({
    required IconData icon,
    required String label,
    required double pulse,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label),
      labelStyle: GoogleFonts.inter(color: Colors.white),
      backgroundColor: Colors.white.withValues(alpha: 0.14 + (0.04 * pulse)),
      shape: StadiumBorder(
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.2 + (0.1 * pulse)),
          width: 1 + (0.5 * pulse),
        ),
      ),
    );
  }

  // Enhanced fade+slide animation with stagger
  Widget _animatedSection({required Widget child, int delayMs = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
