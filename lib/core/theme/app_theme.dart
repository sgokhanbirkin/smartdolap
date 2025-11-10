import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  // Color definitions
  static const Color _primaryBlue = Color(0xFF2196F3);
  static const Color _primaryBlueDark = Color(0xFF1565C0);
  static const Color _accentRed = Color(0xFFE53935);
  static const Color _accentRedDark = Color(0xFFB71C1C);

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


