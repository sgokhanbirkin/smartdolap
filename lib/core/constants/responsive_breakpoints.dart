// ignore_for_file: public_member_api_docs

/// Responsive breakpoints for the application
/// Follows Material Design breakpoints with custom adjustments
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Phone breakpoint (width < 600dp)
  static const double phone = 600;

  /// Tablet breakpoint (600dp <= width < 900dp)
  static const double tablet = 900;

  /// Desktop breakpoint (900dp <= width < 1200dp)
  static const double desktop = 1200;

  /// Large desktop breakpoint (width >= 1200dp)
  static const double largeDesktop = 1800;

  /// Check if width is phone size
  static bool isPhone(double width) => width < phone;

  /// Check if width is tablet size
  static bool isTablet(double width) => width >= phone && width < tablet;

  /// Check if width is desktop size
  static bool isDesktop(double width) => width >= tablet && width < largeDesktop;

  /// Check if width is large desktop size
  static bool isLargeDesktop(double width) => width >= largeDesktop;
}


