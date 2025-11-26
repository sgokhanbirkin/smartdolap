// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';

/// Responsive typography system
/// Follows SOLID principles - Single Responsibility (only typography)
class ResponsiveTypography {
  ResponsiveTypography._();

  /// Get responsive heading text style
  static TextStyle heading(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.textHeading * 1.2 : AppSizes.textHeading,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  /// Get responsive title text style
  static TextStyle title(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.textXL * 1.1 : AppSizes.textXL,
      fontWeight: FontWeight.w600,
      height: 1.3,
    );
  }

  /// Get responsive subtitle text style
  static TextStyle subtitle(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.textL * 1.1 : AppSizes.textL,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
  }

  /// Get responsive body text style
  static TextStyle body(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.text * 1.1 : AppSizes.text,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );
  }

  /// Get responsive body medium text style
  static TextStyle bodyMedium(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.textM * 1.1 : AppSizes.textM,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );
  }

  /// Get responsive body small text style
  static TextStyle bodySmall(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.textS * 1.1 : AppSizes.textS,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );
  }

  /// Get responsive caption text style
  static TextStyle caption(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.textS * 1.1 : AppSizes.textS,
      fontWeight: FontWeight.w400,
      height: 1.4,
    );
  }

  /// Get responsive label text style
  static TextStyle label(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.textM * 1.1 : AppSizes.textM,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
  }

  /// Get responsive button text style
  static TextStyle button(BuildContext context) {
    final bool isTablet = context.isTablet;
    return TextStyle(
      fontSize: isTablet ? AppSizes.textM * 1.1 : AppSizes.textM,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
  }
}

