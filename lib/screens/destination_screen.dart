import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_theme.dart';
import '../data/flight_data.dart';
import '../widgets/background.dart';
import '../widgets/hub_badge.dart';
import 'flight_information.dart';

/// Define the hub airports.
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

/// New set for the biggest airports in the USA.
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


class DestinationScreen extends StatefulWidget {
  final String origin;
  final String flightType;
  final String currentEmployeeId;

  const DestinationScreen({
    super.key,
    required this.origin,
    required this.flightType,
    required this.currentEmployeeId,
  });

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  String _searchQuery = '';
  String _sortOrder = 'a-z';

  /// This list will hold the user's favorite destination airports.
  List<String> favoriteAirports = [];

  /// Navigates to the FlightInformationScreen for the selected destination.
  void _navigateToFlightListScreen(String airport) {
    debugPrint('Flight Type: ${widget.flightType}');

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FlightInformationScreen(
          origin: widget.origin,
          flightType: widget.flightType,
          destination: airport,
          currentEmployeeId: widget.currentEmployeeId,
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

  /// Shows a dialog allowing the user to add a favorite airport.
  /// Only airports not already in hubs, biggest, or favorites are available.
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

  /// Helper to build section headers with an optional trailing widget.
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
              color: AppColors.primary,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exclude the origin from the available destinations.
    final List<String> availableDestinations =
        airports.where((airport) => airport != widget.origin).toList();

    // Filter airports based on the search query.
    final List<String> filteredAirports =
        availableDestinations.where((airport) {
      final query = _searchQuery.toLowerCase();
      return airport.toLowerCase().contains(query) ||
          (airportCodes[airport] ?? '').toLowerCase().contains(query);
    }).toList();

    // Split filtered airports into sections.
    final List<String> hubs = filteredAirports
        .where((airport) => hubAirports.contains(airport))
        .toList();

    final List<String> biggest = filteredAirports.where((airport) {
      return biggestAirportsUSA.contains(airport) &&
          !hubAirports.contains(airport);
    }).toList();

    final List<String> others = filteredAirports.where((airport) {
      return !hubAirports.contains(airport) &&
          !biggestAirportsUSA.contains(airport);
    }).toList();

    // Determine the user's favorite airports.
    final List<String> favorites = favoriteAirports
        .where((airport) => filteredAirports.contains(airport))
        .toList();

    // Create a candidate list for adding favorites.
    final List<String> candidateFavorites = filteredAirports.where((airport) {
      return !hubAirports.contains(airport) &&
          !biggestAirportsUSA.contains(airport) &&
          !favoriteAirports.contains(airport);
    }).toList();

    // Sort each list using the airportCodes mapping if available.
    int compareAirports(String a, String b) {
      final aVal = (airportCodes[a] ?? a).toLowerCase();
      final bVal = (airportCodes[b] ?? b).toLowerCase();
      return _sortOrder == 'a-z' ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    }

    hubs.sort(compareAirports);
    biggest.sort(compareAirports);
    favorites.sort(compareAirports);
    others.sort(compareAirports);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Don't imply a back button
        titleSpacing: 0, // Remove extra spacing on the left
        backgroundColor: AppColors.primary,
        elevation: 4,
        toolbarHeight: 50,
        centerTitle: false, // Allow left alignment
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Image.asset(
                'assets/images/globe.png',
                height: 150, // Adjust as needed
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 0),
              Expanded(
                child: Text(
                  'Destination Airport',
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
            gradient: AppGradients.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3), // Shadow color
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 4), // Moves shadow down
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Background(
          child: Column(
            children: [
              // Search and sort controls.
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: AppColors.primary,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: AppColors.primaryDark,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      tooltip: 'Sort options',
                      color: AppColors.primary,
                      onSelected: (value) => setState(() => _sortOrder = value),
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
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.sort, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Main content with sections.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hubs Section.
                      if (hubs.isNotEmpty) ...[
                        _buildSectionHeader('Hubs'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AlignedGridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            itemCount: hubs.length,
                            itemBuilder: (context, index) {
                              final airport = hubs[index];
                              return SizedBox(
                                height: 100,
                                child: DestinationCard(
                                  destination: airport,
                                  isHub: true,
                                  origin: widget.origin,
                                  flightType: widget.flightType,
                                  currentEmployeeId: widget.currentEmployeeId,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      // Biggest Airports Section.
                      if (biggest.isNotEmpty) ...[
                        _buildSectionHeader('Biggest Airports (USA)'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AlignedGridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            itemCount: biggest.length,
                            itemBuilder: (context, index) {
                              final airport = biggest[index];
                              return SizedBox(
                                height: 100,
                                child: DestinationCard(
                                  destination: airport,
                                  isHub: false,
                                  origin: widget.origin,
                                  flightType: widget.flightType,
                                  currentEmployeeId: widget.currentEmployeeId,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      // Favorite Airports Section.
                      _buildSectionHeader(
                        'Favorite Airports',
                        trailing: IconButton(
                          icon: const Icon(Icons.add, color: AppColors.primary),
                          onPressed: candidateFavorites.isNotEmpty
                              ? () => _showAddFavoriteDialog(candidateFavorites)
                              : null,
                        ),
                      ),
                      if (favorites.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AlignedGridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final airport = favorites[index];
                              return SizedBox(
                                height: 100,
                                child: DestinationCard(
                                  destination: airport,
                                  isHub: hubAirports.contains(airport),
                                  origin: widget.origin,
                                  flightType: widget.flightType,
                                  currentEmployeeId: widget.currentEmployeeId,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'No favorite airports added yet.',
                            style: GoogleFonts.inter(
                              color: AppColors.primary.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      // Other Airports Section.
                      ExpansionTile(
                        title: Text(
                          'Other Airports',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        collapsedIconColor: AppColors.primary,
                        iconColor: AppColors.primary,
                        backgroundColor: Colors.transparent,
                        children: others.map((airport) {
                          return ListTile(
                            title: Text(
                              airportCodes[airport] ?? airport,
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                              ),
                            ),
                            onTap: () => _navigateToFlightListScreen(airport),
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

/// A card widget that displays a destination airport.
class DestinationCard extends StatelessWidget {
  final String destination;
  final bool isHub;
  final String origin;
  final String flightType;
  final String currentEmployeeId; // New field

  const DestinationCard({
    super.key,
    required this.destination,
    required this.isHub,
    required this.origin,
    required this.flightType,
    required this.currentEmployeeId,
  });

  String _getImageAssetPath(String airport) {
    // Use the airport code if available, otherwise fall back to the airport name.
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
      onTap: () {
        // Navigate with a slide-from-right animation to FlightInformationScreen.
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FlightInformationScreen(
              origin: origin,
              flightType: flightType,
              destination: destination,
              currentEmployeeId: currentEmployeeId,
            ),
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
      },
      child: Hero(
        tag: 'destination-$destination',
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
                // Background image.
                Image.asset(
                  _getImageAssetPath(destination),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                ),
                // Gradient overlay.
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                // Hub badge if applicable.
                if (isHub) const Positioned(top: 8, left: 8, child: HubBadge()),
                // Centered airport code or name.
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      airportCodes[destination] ?? destination,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black54,
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
