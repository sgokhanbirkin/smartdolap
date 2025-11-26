// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';

/// Adaptive list widget that adjusts layout based on screen size
/// Follows SOLID principles - Single Responsibility (only list layout)
class AdaptiveList<T> extends StatelessWidget {
  /// Adaptive list constructor
  const AdaptiveList({
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.separatorBuilder,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    super.key,
  });

  /// List items
  final List<T> items;

  /// Item builder function
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// Padding around list
  final EdgeInsetsGeometry? padding;

  /// Separator builder (optional)
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Scroll controller
  final ScrollController? scrollController;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Shrink wrap
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = context.isTablet;
    final EdgeInsetsGeometry listPadding =
        padding ??
        EdgeInsets.all(isTablet ? AppSizes.padding * 1.5 : AppSizes.padding);

    if (separatorBuilder != null) {
      return ListView.separated(
        controller: scrollController,
        padding: listPadding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        shrinkWrap: shrinkWrap,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) =>
        itemBuilder(context, index, items[index]),
        separatorBuilder: separatorBuilder!,
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: listPadding,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) =>
          itemBuilder(context, index, items[index]),
    );
  }
}
