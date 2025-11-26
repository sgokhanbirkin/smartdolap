// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart' as responsive;

/// Adaptive grid widget that adjusts columns based on screen size
/// Follows SOLID principles - Single Responsibility (only grid layout)
class AdaptiveGrid extends StatelessWidget {
  /// Adaptive grid constructor
  const AdaptiveGrid({
    required this.children,
    this.phoneColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.largeDesktopColumns = 5,
    this.spacing,
    this.aspectRatio,
    this.padding,
    super.key,
  });

  /// Grid children
  final List<Widget> children;

  /// Columns for phone screens
  final int phoneColumns;

  /// Columns for tablet screens
  final int tabletColumns;

  /// Columns for desktop screens
  final int desktopColumns;

  /// Columns for large desktop screens
  final int largeDesktopColumns;

  /// Spacing between items (optional, uses responsive default if null)
  final double? spacing;

  /// Aspect ratio for items (optional, uses responsive default if null)
  final double? aspectRatio;

  /// Padding around grid
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = context.responsiveInt(
      phone: phoneColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      largeDesktop: largeDesktopColumns,
    );

    final double itemSpacing =
        spacing ?? responsive.ResponsiveGrid.getSpacing(context);
    final double itemAspectRatio =
        aspectRatio ?? responsive.ResponsiveGrid.getChildAspectRatio(context);

    return GridView.builder(
      padding: padding ?? EdgeInsets.all(AppSizes.padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: itemSpacing,
        mainAxisSpacing: itemSpacing,
        childAspectRatio: itemAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (BuildContext context, int index) => children[index],
    );
  }
}
