import 'package:flutter/material.dart';

/// Responsive helper extensions for common operations
extension ResponsiveExtensions on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if screen is small (width < 600)
  bool get isSmallScreen => screenWidth < 600;

  /// Check if screen is medium (600 <= width < 900)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;

  /// Check if screen is large (width >= 900)
  bool get isLargeScreen => screenWidth >= 900;

  /// Check if screen is tablet size (width >= 600)
  bool get isTablet => screenWidth >= 600;

  /// Check if screen is phone size (width < 600)
  bool get isPhone => screenWidth < 600;
}

/// Responsive grid helper
class ResponsiveGrid {
  ResponsiveGrid._();

  /// Calculate responsive grid cross axis count based on screen width
  ///
  /// - Small screens (< 600): 2 columns
  /// - Medium screens (600-900): 3 columns
  /// - Large screens (>= 900): 4 columns
  static int getCrossAxisCount(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2; // Small screens: 2 columns
    } else if (screenWidth < 900) {
      return 3; // Medium screens: 3 columns
    } else {
      return 4; // Large screens: 4 columns
    }
  }

  /// Calculate responsive grid cross axis count with custom breakpoints
  static int getCrossAxisCountCustom(
    BuildContext context, {
    int smallColumns = 2,
    int mediumColumns = 3,
    int largeColumns = 4,
    double smallBreakpoint = 600,
    double mediumBreakpoint = 900,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < smallBreakpoint) {
      return smallColumns;
    } else if (screenWidth < mediumBreakpoint) {
      return mediumColumns;
    } else {
      return largeColumns;
    }
  }

  /// Calculate responsive child aspect ratio for grid items
  static double getChildAspectRatio(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 0.75; // Taller items on small screens
    } else if (screenWidth < 900) {
      return 0.85; // Medium aspect ratio
    } else {
      return 0.9; // Wider items on large screens
    }
  }
}
