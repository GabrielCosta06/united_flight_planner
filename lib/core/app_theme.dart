import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised palette for the application.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0066CC); // Stronger, more vibrant blue
  static const Color primaryDark = Color(0xFF003D7A);
  static const Color primaryLight = Color(0xFF3399FF);
  static const Color surface = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color accent = Color(0xFF00B4D8);
}

/// Commonly used gradients.
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryVibrant = LinearGradient(
    colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.accent, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Reusable theme definition for the app.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.interTextTheme(),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    return base.copyWith(
      dividerTheme: const DividerThemeData(color: Color(0xFFCFD3D6), thickness: 1.5),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
