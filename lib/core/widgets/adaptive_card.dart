// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';

/// Adaptive card widget that adjusts padding and elevation based on screen size
/// Follows SOLID principles - Single Responsibility (only card styling)
class AdaptiveCard extends StatelessWidget {
  /// Adaptive card constructor
  const AdaptiveCard({
    required this.child,
    this.margin,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.color,
    this.onTap,
    super.key,
  });

  /// Card content
  final Widget child;

  /// Margin around card
  final EdgeInsetsGeometry? margin;

  /// Padding inside card
  final EdgeInsetsGeometry? padding;

  /// Card elevation (responsive if null)
  final double? elevation;

  /// Border radius (responsive if null)
  final BorderRadius? borderRadius;

  /// Card color
  final Color? color;

  /// Tap callback
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = context.isTablet;

    final EdgeInsetsGeometry cardPadding = padding ??
        EdgeInsets.all(
          isTablet ? AppSizes.padding * 1.5 : AppSizes.padding,
        );

    final double cardElevation = elevation ??
        (isTablet ? AppSizes.cardElevation * 1.5 : AppSizes.cardElevation);

    final BorderRadius cardBorderRadius = borderRadius ??
        BorderRadius.circular(
          isTablet ? AppSizes.radiusL : AppSizes.radius,
        );

    Widget card = Card(
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: cardBorderRadius,
      ),
      color: color,
      margin: margin ?? EdgeInsets.all(AppSizes.spacingS),
      child: Padding(
        padding: cardPadding,
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

