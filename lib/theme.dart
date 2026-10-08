import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colours taken from the Foxcrypto Figma style guide.
class AppColors {
  static const background = Color(0xFF16171D); // brand dark
  static const surface = Color(0xFF21242D); // inputs, cards
  static const card = Color(0xFF282B35); // coin chart cards
  static const tabBar = Color(0xFF23262E);
  static const stroke = Color(0xFF494D58);
  static const hint = Color(0xFF535764);
  static const primary = Color(0xFFF5C249); // brand yellow
  static const text = Color(0xFFF8F8F8);
  static const muted = Color(0xFFA7AEBF);
  static const dim = Color(0xFF787A8D);
  static const success = Color(0xFF00C566);
  static const danger = Color(0xFFFF403B);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        surface: AppColors.background,
        onSurface: AppColors.text,
        error: AppColors.danger,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
