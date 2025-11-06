import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  /// Light theme
  static ThemeData light() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF29A36C)),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }

  /// Dark theme
  static ThemeData dark() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF29A36C),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }
}
