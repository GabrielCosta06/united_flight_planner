import 'package:flutter/material.dart';
import '../widgets/background.dart';
import 'destination_screen.dart';
import '../data/flight_data.dart';

class FlightTypeScreen extends StatelessWidget {
  final String origin;
  final String currentEmployeeId; // New field

  const FlightTypeScreen({
    super.key,
    required this.origin,
    required this.currentEmployeeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: const Color.fromARGB(255, 23, 0, 65),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
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
        title: Row(
          children: [
            Image.asset(
              'assets/images/globe.png',
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 4), // Small gap between the globe and arrow
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(
                width: 4), // Small gap between the arrow and the title
            const Text(
              'Select Flight Type',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Background(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: flightTypes.length,
            itemBuilder: (context, index) {
              final type = flightTypes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Hero(
                  tag: 'flightType-$type',
                  child: Material(
                    color: Colors.transparent,
                    child: Card(
                      color: unitedBlue,
                      child: ListTile(
                        title: Text(
                          type,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: Colors.white),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      DestinationScreen(
                                origin: origin,
                                flightType: type,
                                currentEmployeeId:
                                    currentEmployeeId, // Use the field directly
                              ),
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 300),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
