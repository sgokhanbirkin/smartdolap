import 'package:flutter/material.dart';

/// Unified color palette for the application
class AppColors {
  AppColors._();

  // Primary colors
  /// Primary red color (#E53935)
  static const Color primaryRed = Color(0xFFE53935);

  /// Primary blue color (#2196F3)
  static const Color primaryBlue = Color(0xFF2196F3);

  // Dark mode variants
  /// Dark mode primary red (#B71C1C)
  static const Color primaryRedDark = Color(0xFFB71C1C);

  /// Dark mode primary blue (#1565C0)
  static const Color primaryBlueDark = Color(0xFF1565C0);

  // Background colors
  /// Light background color
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// Dark background color
  static const Color backgroundDark = Color(0xFF121212);

  // Surface colors
  /// Light surface color
  static const Color surfaceLight = Color(0xFFF5F5F5);

  /// Dark surface color
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text colors
  /// Dark text color (for light backgrounds)
  static const Color textDark = Color(0xFF212121);

  /// Light text color (for dark backgrounds)
  static const Color textLight = Color(0xFFFFFFFF);

  /// Medium text color (for secondary text)
  static const Color textMedium = Color(0xFF757575);

  // Gradient
  /// Red to blue gradient (topLeft → bottomRight)
  static const LinearGradient redToBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      primaryRed,
      primaryBlue,
    ],
  );

  /// Red to blue gradient (dark mode variant)
  static const LinearGradient redToBlueDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      primaryRedDark,
      primaryBlueDark,
    ],
  );
}
