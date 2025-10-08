import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/hub_badge.dart';
import '../widgets/background.dart';
import 'flight_type_screen.dart';
import '../data/flight_data.dart';

const Set<String> hubAirports = {
  'Chicago O\'Hare',
  'Denver International Airport',
  'Houston Intercontinental Airport',
  'LAX International',
  'Newark Liberty International Airport',
  'San Francisco International Airport',
  'Washington Dulles International Airport',
  'Antonio B. Won Pat International Airport',
};

const Set<String> biggestAirportsUSA = {
  'Hartsfield-Jackson Atlanta International Airport',
  'Los Angeles International Airport',
  "O'Hare International Airport",
  'Dallas/Fort Worth International Airport',
  'Denver International Airport',
  'John F. Kennedy International Airport',
  'San Francisco International Airport',
  'Seattle-Tacoma International Airport',
};

const unitedBlue = Color.fromARGB(255, 0, 77, 155);

class OriginScreen extends StatefulWidget {
  final String currentEmployeeId; // Added property

  const OriginScreen({super.key, required this.currentEmployeeId});

  @override
  _OriginScreenState createState() => _OriginScreenState();
}

class _OriginScreenState extends State<OriginScreen> {
  String _searchQuery = '';
  String _sortOrder = 'a-z';
  List<String> favoriteAirports = [];

  List<String> getFilteredAirports() {
    final query = _searchQuery.toLowerCase();
    return airports.where((airport) {
      return airport.toLowerCase().contains(query) ||
          (airportCodes[airport] ?? '').toLowerCase().contains(query);
    }).toList();
  }

  int compareAirports(String a, String b) {
    final aVal = (airportCodes[a] ?? a).toLowerCase();
    final bVal = (airportCodes[b] ?? b).toLowerCase();
    return _sortOrder == 'a-z' ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
  }

  List<String> sortAirports(List<String> list) {
    list.sort(compareAirports);
    return list;
  }

  void _navigateToFlightTypeScreen(String airport) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FlightTypeScreen(
          origin: airport,
          currentEmployeeId: widget.currentEmployeeId, // Use the new field
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _showAddFavoriteDialog(List<String> candidateAirports) {
    String? selectedAirport;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Favorite Airport',
            style: GoogleFonts.inter(),
          ),
          content: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Airport',
              labelStyle: GoogleFonts.inter(),
            ),
            items: candidateAirports.map((airport) {
              return DropdownMenuItem(
                value: airport,
                child: Text(
                  airportCodes[airport] ?? airport,
                  style: GoogleFonts.inter(),
                ),
              );
            }).toList(),
            onChanged: (value) {
              selectedAirport = value;
            },
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(
                'Add',
                style: GoogleFonts.inter(),
              ),
              onPressed: () {
                if (selectedAirport != null) {
                  setState(() {
                    favoriteAirports.add(selectedAirport!);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredAirports();
    final hubs = sortAirports(
        filtered.where((airport) => hubAirports.contains(airport)).toList());
    final biggest = sortAirports(filtered
        .where((airport) =>
            biggestAirportsUSA.contains(airport) &&
            !hubAirports.contains(airport))
        .toList());
    final favorites = sortAirports(favoriteAirports
        .where((airport) => filtered.contains(airport))
        .toList());
    final others = sortAirports(filtered
        .where((airport) =>
            !hubAirports.contains(airport) &&
            !biggestAirportsUSA.contains(airport) &&
            !favoriteAirports.contains(airport))
        .toList());
    final candidateFavorites = filtered.where((airport) {
      return !hubAirports.contains(airport) &&
          !biggestAirportsUSA.contains(airport) &&
          !favoriteAirports.contains(airport);
    }).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leadingWidth: 0,
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
                ),
                const SizedBox(width: 10),
                Text(
                  'Origin Airport',
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
              gradient: const LinearGradient(
                colors: [unitedBlue, Color.fromARGB(255, 23, 0, 65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Shadow color
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 4), // Moves shadow down
                ),
              ],
            ),
          ),
        ),
        body: Background(
          child: Column(
            children: [
              SearchAndSortBar(
                searchQuery: _searchQuery,
                sortOrder: _sortOrder,
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
                onSortSelected: (value) => setState(() => _sortOrder = value),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hubs.isNotEmpty)
                        AirportGridSection(
                          title: 'Hubs',
                          airports: hubs,
                          isHubResolver: (_) => true,
                          onTap: _navigateToFlightTypeScreen,
                        ),
                      if (biggest.isNotEmpty)
                        AirportGridSection(
                          title: 'Biggest Airports (USA)',
                          airports: biggest,
                          isHubResolver: (_) => false,
                          onTap: _navigateToFlightTypeScreen,
                        ),
                      AirportGridSection(
                        title: 'Favorite Airports',
                        airports: favorites,
                        trailing: IconButton(
                          icon: const Icon(Icons.add, color: unitedBlue),
                          onPressed: candidateFavorites.isNotEmpty
                              ? () => _showAddFavoriteDialog(candidateFavorites)
                              : null,
                        ),
                        isHubResolver: (airport) =>
                            hubAirports.contains(airport),
                        onTap: _navigateToFlightTypeScreen,
                      ),
                      if (favorites.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'No favorite airports added yet.',
                            style: GoogleFonts.inter(
                              color: unitedBlue.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ExpansionTile(
                        title: Text(
                          'Other Airports',
                          style: GoogleFonts.inter(
                            color: unitedBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        collapsedIconColor: unitedBlue,
                        iconColor: unitedBlue,
                        backgroundColor: Colors.transparent,
                        children: others.map((airport) {
                          return ListTile(
                            title: Text(
                              airportCodes[airport] ?? airport,
                              style: GoogleFonts.inter(
                                color: unitedBlue,
                              ),
                            ),
                            onTap: () => _navigateToFlightTypeScreen(airport),
                          );
                        }).toList(),
                      ),
                    ],
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

class SearchAndSortBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String sortOrder;
  final ValueChanged<String> onSortSelected;
  const SearchAndSortBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortOrder,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Search airports...',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: unitedBlue,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide:
                      const BorderSide(color: Colors.deepPurple, width: 1.5),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: 'Sort options',
            color: unitedBlue,
            onSelected: onSortSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'a-z',
                child: Text(
                  'Sort A to Z',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'z-a',
                child: Text(
                  'Sort Z to A',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                color: unitedBlue,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.sort, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class AirportGridSection extends StatelessWidget {
  final String title;
  final List<String> airports;
  final Widget? trailing;
  final bool Function(String) isHubResolver;
  final Function(String) onTap;
  const AirportGridSection({
    super.key,
    required this.title,
    required this.airports,
    this.trailing,
    required this.isHubResolver,
    required this.onTap,
  });

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: unitedBlue,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(title, trailing: trailing),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AlignedGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemCount: airports.length,
            itemBuilder: (context, index) {
              final airport = airports[index];
              final isHub = isHubResolver(airport);
              return SizedBox(
                height: 100,
                child: AirportCard(
                  airport: airport,
                  isHub: isHub,
                  onTap: () => onTap(airport),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AirportCard extends StatelessWidget {
  final String airport;
  final bool isHub;
  final VoidCallback onTap;
  const AirportCard({
    super.key,
    required this.airport,
    required this.isHub,
    required this.onTap,
  });

  String _getImageAssetPath(String airport) {
    final code = airportCodes[airport] ?? airport;
    final sanitized = code
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'assets/airports/$sanitized.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'origin-$airport',
        child: Material(
          color: Colors.transparent,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _getImageAssetPath(airport),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                if (isHub) const Positioned(top: 8, left: 8, child: HubBadge()),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      airportCodes[airport] ?? airport,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: unitedBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
