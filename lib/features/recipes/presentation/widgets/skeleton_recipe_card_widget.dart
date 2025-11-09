import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Skeleton loading card widget for recipe cards
class SkeletonRecipeCardWidget extends StatelessWidget {
  const SkeletonRecipeCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Color skeletonColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Category chip skeleton
              Padding(
                padding: EdgeInsets.only(
                  left: AppSizes.spacingS,
                  right: AppSizes.spacingS,
                  top: AppSizes.spacingS,
                ),
                child: Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Image area skeleton
              Expanded(child: Container(color: skeletonColor)),
              // Title and ingredients skeleton
              Padding(
                padding: EdgeInsets.all(AppSizes.spacingS),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingXS * 0.5),
                    Container(
                      width: double.infinity * 0.7,
                      height: 12,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(
          onPlay: (AnimationController controller) => controller.repeat(),
        )
        .shimmer(
          duration: 1200.ms,
          color: skeletonColor.withValues(alpha: 0.5),
        );
  }
}
