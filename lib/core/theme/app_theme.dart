import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  // Color definitions
  static const Color _primaryBlue = Color(0xFF2196F3);
  static const Color _primaryBlueDark = Color(0xFF1565C0);
  // Lighter red for better contrast and readability
  static const Color _accentRed = Color(0xFFEF5350); // Lighter red (#E53935 -> #EF5350)
  static const Color _accentRedDark = Color(0xFFD32F2F); // Lighter dark red (#B71C1C -> #D32F2F)

  /// Light theme
  static ThemeData light() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    // Create color scheme with blue as primary and red as secondary
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.light,
    ).copyWith(
      secondary: _accentRed,
      error: _accentRed,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: _accentRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        indicatorColor: Colors.white,
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentRed,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentRed,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentRed,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentRed,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// Dark theme
  static ThemeData dark() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    // Create color scheme with darker blue as primary and darker red as secondary
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlueDark,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _primaryBlueDark,
      secondary: _accentRedDark,
      error: _accentRedDark,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: _accentRedDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        indicatorColor: Colors.white,
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentRedDark,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentRedDark,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentRedDark,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentRedDark,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}


