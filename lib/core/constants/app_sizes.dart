import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App sizes using ScreenUtil
class AppSizes {
  AppSizes._();

  // Spacing
  /// Extra small spacing (4dp)
  static double get spacingXS => 4.w;

  /// Small spacing (8dp)
  static double get spacingS => 8.w;

  /// Medium spacing (12dp)
  static double get spacingM => 12.w;

  /// Standard padding (16dp)
  static double get padding => 16.w;

  /// Large spacing (20dp)
  static double get spacingL => 20.w;

  /// Extra large spacing (24dp)
  static double get spacingXL => 24.w;

  /// Extra extra large spacing (32dp)
  static double get spacingXXL => 32.w;

  // Vertical spacing
  /// Small vertical spacing (8dp)
  static double get verticalSpacingS => 8.h;

  /// Medium vertical spacing (12dp)
  static double get verticalSpacingM => 12.h;

  /// Standard vertical spacing (16dp)
  static double get verticalSpacing => 16.h;

  /// Large vertical spacing (20dp)
  static double get verticalSpacingL => 20.h;

  /// Extra large vertical spacing (24dp)
  static double get verticalSpacingXL => 24.h;

  /// Extra extra large vertical spacing (32dp)
  static double get verticalSpacingXXL => 32.h;

  // Border radius
  /// Small radius (4dp)
  static double get radiusS => 4.r;

  /// Medium radius (8dp)
  static double get radiusM => 8.r;

  /// Standard radius (12dp)
  static double get radius => 12.r;

  /// Large radius (16dp)
  static double get radiusL => 16.r;

  /// Extra large radius (24dp)
  static double get radiusXL => 24.r;

  // Button sizes
  /// Button height (48dp)
  static double get buttonHeight => 48.h;

  /// Small button height (40dp)
  static double get buttonHeightS => 40.h;

  /// Large button height (56dp)
  static double get buttonHeightL => 56.h;

  /// Button horizontal padding
  static double get buttonPaddingH => 16.w;

  /// Button vertical padding
  static double get buttonPaddingV => 12.h;

  // Icon sizes
  /// Extra small icon (16dp)
  static double get iconXS => 16.sp;

  /// Small icon (20dp)
  static double get iconS => 20.sp;

  /// Standard icon size (24dp)
  static double get icon => 24.sp;

  /// Large icon (32dp)
  static double get iconL => 32.sp;

  /// Extra large icon (40dp)
  static double get iconXL => 40.sp;

  /// Extra extra large icon (56dp)
  static double get iconXXL => 56.sp;

  // Card dimensions
  /// Card padding
  static double get cardPadding => 16.w;

  /// Card radius
  static double get cardRadius => 12.r;

  /// Card elevation
  static double get cardElevation => 2.0;

  // Text sizes (using sp for font scaling)
  /// Extra small text (10sp)
  static double get textXS => 10.sp;

  /// Small text (12sp)
  static double get textS => 12.sp;

  /// Medium text (14sp)
  static double get textM => 14.sp;

  /// Standard text (16sp)
  static double get text => 16.sp;

  /// Large text (18sp)
  static double get textL => 18.sp;

  /// Extra large text (24sp)
  static double get textXL => 24.sp;

  /// Heading text (28sp)
  static double get textHeading => 28.sp;

  // Touch targets
  /// Minimum touch target size (48dp)
  static double get touchTarget => 48.w;

  // AppBar
  /// AppBar height
  static double get appBarHeight => 56.h;

  /// AppBar elevation
  static double get appBarElevation => 0.0;

  // Bottom navigation
  /// Bottom navigation bar height
  static double get bottomNavHeight => 64.h;
}
