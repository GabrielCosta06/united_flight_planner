import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/background.dart';
import '../widgets/upcoming_flights_card.dart';
import '../widgets/news_card.dart';
import '../widgets/accommodations_transportations.dart';
import '../widgets/tips_forum.dart';
import '../widgets/atc_weather_status.dart';
import 'flight_status_screen.dart';
import 'origin_screen.dart';
import 'account_screen.dart';
import 'trips_screen.dart';
import '../data/flight_data.dart' as flight_data;
import '../data/employee_data.dart';
import 'flight_list_screen.dart';

const Color unitedBlue = Color(0xFF005DAA);

// Global key for the DashboardScreen state (if needed).
final GlobalKey<_DashboardScreenState> dashboardKey =
    GlobalKey<_DashboardScreenState>();

void main() {
  loadEmployeeData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'United Airlines App',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: MainPage(currentEmployeeId: 'example_employee_id'),
    );
  }
}

class MainPage extends StatefulWidget {
  final String currentEmployeeId;
  const MainPage({super.key, required this.currentEmployeeId});

  @override
  _MainPageState createState() => _MainPageState();
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
      // If switching to Home or re-tapping Home, update selected index and then refresh.
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
        // Call refresh after the Home screen has been built.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          upcomingFlightsKey.currentState?.refreshFlights();
        });
      } else {
        // If already on Home, simply refresh.
        upcomingFlightsKey.currentState?.refreshFlights();
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      }
    } else {
      // For other tabs, just update the selected index.
      setState(() {
        _selectedIndex = index;
      });
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
                    upcomingFlightsKey: upcomingFlightsKey, // pass the key
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
              builder = (context) => FlightStatusScreen(
                  currentEmployeeId: widget.currentEmployeeId);
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
        selectedItemColor: unitedBlue,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.flight_takeoff), label: 'Book flight'),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_travel), label: 'Trips'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_airport), label: 'Flight Status'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// Update DashboardScreen to accept the upcomingFlightsKey.
class DashboardScreen extends StatefulWidget {
  final String employeeId;
  final GlobalKey<UpcomingFlightsWidgetState> upcomingFlightsKey;
  const DashboardScreen(
      {super.key, required this.employeeId, required this.upcomingFlightsKey});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Recalculate header info on each build.
    final employee = employees.firstWhere(
      (emp) => emp.username == widget.employeeId,
      orElse: () => Employee(
        employeeId: widget.employeeId,
        name: widget.employeeId,
        username: '',
        email: '',
        password: '',
        abbreviatedName: '',
        abbreviatedName2: '',
        profileImagePath: '',
        passType: '',
      ),
    );

    final allFlights =
        flight_data.fakeFlights.values.expand((list) => list).toList();
    final upcomingFlights = allFlights.where((flight) {
      bool isUpcoming = flight.departureTime.isAfter(DateTime.now());
      bool isBooked = flight.confirmedPassengers.values
          .any((list) => list.contains(widget.employeeId));
      return isUpcoming && isBooked;
    }).toList();
    final upcomingCount = upcomingFlights.length;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            leadingWidth: 0,
            pinned: true,
            backgroundColor: unitedBlue,
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
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Welcome, ${employee.abbreviatedName2}!',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
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
        ];
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Upcoming Flights',
              icon: Icons.flight,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlightListScreen(
                            origin: '',
                            flightType: 'Domestic',
                            destination: '',
                            departureDate: DateTime.now(),
                            stops: 'Any',
                            tripType: 'One-way',
                            travelAdvisories: '',
                            employeeNotes: [],
                            currentEmployeeId: widget.employeeId,
                            filterOpenSeats: true,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: unitedBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Flights with open seats',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: unitedBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$upcomingCount',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Use the upcomingFlightsKey to build the UpcomingFlightsWidget.
            UpcomingFlightsWidget(
              key: widget.upcomingFlightsKey,
              currentEmployeeId: widget.employeeId,
            ),
            // ... (rest of your UI, e.g., Latest News, Accommodations, etc.)
            const SizedBox(height: 24),
            const SectionHeader(title: 'Latest News', icon: Icons.article),
            const SizedBox(height: 12),
            const NewsSection(),
            const SizedBox(height: 24),
            const SectionHeader(
                title: 'Accommodations & Transportation Options',
                icon: Icons.emoji_transportation_rounded),
            const SizedBox(height: 12),
            const AccommodationsTransportations(),
            const SizedBox(height: 24),
            const SectionHeader(
                title: 'Travel Tips (Forum)', icon: Icons.forum),
            const SizedBox(height: 12),
            const TravelTipsForum(),
            const SizedBox(height: 24),
            const SectionHeader(
                title: 'Weather/ATC Status', icon: Icons.wb_sunny),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 2,
              child: USAStatusMap(
                airports: [
                  AirportStatus(
                      airportName: 'SFO',
                      terminal: 'Terminal 1',
                      severity: SeverityLevel.normal),
                  AirportStatus(
                      airportName: 'LAX',
                      terminal: 'Terminal 2',
                      severity: SeverityLevel.low),
                  AirportStatus(
                      airportName: 'DEN',
                      terminal: 'Terminal 3',
                      severity: SeverityLevel.medium),
                  AirportStatus(
                      airportName: 'ORD',
                      terminal: 'Terminal 4',
                      severity: SeverityLevel.high),
                  AirportStatus(
                      airportName: 'EWR',
                      terminal: 'Terminal 5',
                      severity: SeverityLevel.extreme),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const StatusKey(),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'United Airlines © 2025. All rights reserved.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              if (icon != null) Icon(icon, color: unitedBlue),
              if (icon != null) const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        Divider(color: const Color.fromARGB(255, 207, 207, 207), thickness: 2),
      ],
    );
  }
}
