import 'package:flutter/material.dart';
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

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List.generate(5, (index) => GlobalKey<NavigatorState>());

  // Create a GlobalKey for the UpcomingFlightsWidget state.
  final GlobalKey<UpcomingFlightsWidgetState> upcomingFlightsKey =
      GlobalKey<UpcomingFlightsWidgetState>();

  void _onBottomNavItemTapped(int index) {
    if (index == 0) {
      if (_selectedIndex != 0) {
        setState(() => _selectedIndex = 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          upcomingFlightsKey.currentState?.refreshFlights();
        });
      } else {
        upcomingFlightsKey.currentState?.refreshFlights();
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      }
    } else {
      setState(() => _selectedIndex = index);
    }
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Trips'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_airport), label: 'Flight Status'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
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

class DashboardScreenState extends State<DashboardScreen> {
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
          backgroundColor: AppColors.surface,
          elevation: innerBoxIsScrolled ? 4 : 0,
          titleSpacing: 16,
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  _initials(employee),
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ', ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Let\'s plan your next standby adventure',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh flights',
              onPressed: () {
                widget.upcomingFlightsKey.currentState?.refreshFlights();
                setState(() {});
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroCard(
              context,
              employee,
              nextFlight,
              upcomingCount,
            ),
            const SizedBox(height: 20),
            _buildQuickStatsRow(
              upcomingCount,
              standbyPassengers,
              openSeatsToday,
            ),
            const SizedBox(height: 28),
            _buildSectionTitle(
              'Upcoming flights',
              caption: 'Track your standby opportunities at a glance',
            ),
            const SizedBox(height: 12),
            UpcomingFlightsWidget(
              key: widget.upcomingFlightsKey,
              currentEmployeeId: widget.employeeId,
            ),
            const SizedBox(height: 28),
            Row(
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
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('Quick actions'),
            const SizedBox(height: 12),
            _buildQuickActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    Employee employee,
    flight_data.Flight? nextFlight,
    int upcomingCount,
  ) {
    final bool hasUpcoming = nextFlight != null;
    final String routeLabel = hasUpcoming
        ? ' ? '
        : 'Choose a route to get live seat updates';
    final String timingLabel = hasUpcoming
        ? DateFormat('EEE, MMM d at h:mm a').format(nextFlight.departureTime)
        : 'See seat forecasts across the network';
    final String seatLabel = hasUpcoming
        ? ' open seats,  on standby'
        : 'Standby availability refreshes every few minutes';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasUpcoming
                ? 'Your next standby chance'
                : 'Welcome back, ',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            routeLabel,
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
              Text(
                timingLabel,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.8),
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
              Text(
                seatLabel,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TripsScreen(currentEmployeeId: widget.employeeId),
                    ),
                  );
                },
                child: Text(
                  hasUpcoming ? 'View standby list' : 'Explore standby routes',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          OriginScreen(currentEmployeeId: widget.employeeId),
                    ),
                  );
                },
                child: Text(
                  'Plan new trip',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Chip(
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                label: Text(
                  ' standby segments saved',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(
    int upcomingCount,
    int standbyPassengers,
    int openSeatsToday,
  ) {
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
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    String? caption,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
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
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? caption}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
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
    );
  }

  Widget _buildOperationalCard({
    required BuildContext context,
    required int standbyPassengers,
    required int openSeatsToday,
    required flight_data.Flight? busiestFlight,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard_customize, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Operational snapshot',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOperationalRow(
              context: context,
              icon: Icons.airlines,
              label: ' flights with open cabins today',
              color: Colors.teal,
            ),
            const SizedBox(height: 12),
            _buildOperationalRow(
              context: context,
              icon: Icons.groups,
              label:
                  ' travelers waiting across the network',
              color: Colors.orange,
            ),
            if (busiestFlight != null) ...[
              const SizedBox(height: 12),
              _buildOperationalRow(
                context: context,
                icon: Icons.local_fire_department,
                label:
                    'Busiest route:  ? ',
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        OriginScreen(currentEmployeeId: widget.employeeId),
                  ),
                );
              },
              label: Text(
                'Search flights',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
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
                'View trips',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AccountScreen(currentEmployeeId: widget.employeeId),
                  ),
                );
              },
              label: Text(
                'My profile',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
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
}
