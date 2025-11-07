import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Shimmer loading card widget for recipes
class ShimmerCardWidget extends StatelessWidget {
  const ShimmerCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Color baseColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    final Color highlightColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Category chip shimmer
            Padding(
              padding: EdgeInsets.only(
                left: AppSizes.cardPadding,
                right: AppSizes.cardPadding,
                top: AppSizes.cardPadding,
              ),
              child: Container(
                height: AppSizes.iconS * 1.2,
                width: AppSizes.spacingXXL * 2.5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
              ),
            ),
            // Image shimmer
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Theme.of(context).colorScheme.surface),
            ),
            // Title and ingredients shimmer
            Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: AppSizes.text,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingS),
                  Container(
                    height: AppSizes.text,
                    width: AppSizes.spacingXXL * 3.75,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingS),
                  Container(
                    height: AppSizes.textS,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingXS),
                  Container(
                    height: AppSizes.textS,
                    width: AppSizes.spacingXXL * 3.125,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
