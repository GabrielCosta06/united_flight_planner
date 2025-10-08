import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'data/employee_data.dart';
import 'screens/login_screen.dart';
import 'screens/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  loadEmployeeData();
  runApp(const FlightPlannerApp());
}

class FlightPlannerApp extends StatelessWidget {
  const FlightPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Traveler',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        MainPage.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as MainPageArguments?;
          assert(args != null, 'MainPage.routeName expects MainPageArguments');
          if (args == null) {
            return const Scaffold(
              body: Center(
                child: Text('Missing navigation data for MainPage'),
              ),
            );
          }
          return MainPage(currentEmployeeId: args.currentEmployeeId);
        },
      },
      initialRoute: LoginScreen.routeName,
    );
  }
}
