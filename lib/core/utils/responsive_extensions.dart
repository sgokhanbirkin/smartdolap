import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/responsive_breakpoints.dart';

/// Responsive helper extensions for common operations
/// Follows SOLID principles - Single Responsibility (only responsive helpers)
extension ResponsiveExtensions on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get screen orientation
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Check if screen is landscape
  bool get isLandscape => orientation == Orientation.landscape;

  /// Check if screen is portrait
  bool get isPortrait => orientation == Orientation.portrait;

  /// Check if screen is phone size (width < 600)
  bool get isPhone => ResponsiveBreakpoints.isPhone(screenWidth);

  /// Check if screen is tablet size (600 <= width < 900)
  bool get isTablet => ResponsiveBreakpoints.isTablet(screenWidth);

  /// Check if screen is desktop size (900 <= width < 1200)
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(screenWidth);

  /// Check if screen is large desktop size (width >= 1200)
  bool get isLargeDesktop => ResponsiveBreakpoints.isLargeDesktop(screenWidth);

  /// Get responsive value based on screen size
  /// Returns phone value for phone, tablet value for tablet, desktop value for desktop
  T responsiveValue<T>({
    required T phone,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop && largeDesktop != null) {
      return largeDesktop;
    }
    if (isDesktop && desktop != null) {
      return desktop;
    }
    if (isTablet && tablet != null) {
      return tablet;
    }
    return phone;
  }

  /// Get responsive double value (for spacing, sizes, etc.)
  double responsiveDouble({
    required double phone,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) => responsiveValue<double>(
      phone: phone,
      tablet: tablet ?? phone * 1.2,
      desktop: desktop ?? phone * 1.5,
      largeDesktop: largeDesktop ?? phone * 2.0,
    );

  /// Get responsive int value (for counts, columns, etc.)
  int responsiveInt({
    required int phone,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) => responsiveValue<int>(
      phone: phone,
      tablet: tablet ?? phone,
      desktop: desktop ?? phone,
      largeDesktop: largeDesktop ?? phone,
    );
}

/// Responsive grid helper
/// Follows SOLID principles - Single Responsibility (only grid calculations)
class ResponsiveGrid {
  ResponsiveGrid._();

  /// Calculate responsive grid cross axis count based on screen width
  ///
  /// - Phone (< 600): 2 columns
  /// - Tablet (600-900): 3 columns
  /// - Desktop (>= 900): 4 columns
  static int getCrossAxisCount(BuildContext context) => context.responsiveInt(
      phone: 2,
      tablet: 3,
      desktop: 4,
      largeDesktop: 5,
    );

  /// Calculate responsive grid cross axis count with custom values
  static int getCrossAxisCountCustom(
    BuildContext context, {
    int phoneColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
    int largeDesktopColumns = 5,
  }) => context.responsiveInt(
      phone: phoneColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      largeDesktop: largeDesktopColumns,
    );

  /// Calculate responsive child aspect ratio for grid items
  static double getChildAspectRatio(BuildContext context) => context.responsiveDouble(
      phone: 0.75, // Taller items on phone
      tablet: 0.85, // Medium aspect ratio
      desktop: 0.9, // Wider items on desktop
      largeDesktop: 0.95, // Even wider on large desktop
    );

  /// Calculate responsive spacing for grid items
  static double getSpacing(BuildContext context) => context.responsiveDouble(
      phone: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    );

  /// Calculate responsive main axis spacing for grid items
  static double getMainAxisSpacing(BuildContext context) => context.responsiveDouble(
      phone: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    );
}
