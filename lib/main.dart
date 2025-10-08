import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FlightPlannerApp());
}

class FlightPlannerApp extends StatelessWidget {
  const FlightPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Traveler',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), // Start with the LoginScreen
    );
  }
}
