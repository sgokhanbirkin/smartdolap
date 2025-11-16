// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Skeleton loading widget for recipe cards
class RecipeCardSkeleton extends StatelessWidget {
  const RecipeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Category chip skeleton
        Padding(
          padding: EdgeInsets.only(
            left: AppSizes.cardPadding,
            right: AppSizes.cardPadding,
            top: AppSizes.cardPadding,
          ),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.surface,
            child: Container(
              width: 80.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
            ),
          ),
        ),
        // Image skeleton
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.surface,
            child: Container(
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ),
        // Content skeleton
        Padding(
          padding: EdgeInsets.all(AppSizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title skeleton
              Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                highlightColor: Theme.of(context).colorScheme.surface,
                child: Container(
                  width: double.infinity,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingS),
              Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                highlightColor: Theme.of(context).colorScheme.surface,
                child: Container(
                  width: 150.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              // Ingredients skeleton
              Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                highlightColor: Theme.of(context).colorScheme.surface,
                child: Container(
                  width: double.infinity,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingS),
              Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                highlightColor: Theme.of(context).colorScheme.surface,
                child: Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              // Badges skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    highlightColor: Theme.of(context).colorScheme.surface,
                    child: Container(
                      width: 70.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    highlightColor: Theme.of(context).colorScheme.surface,
                    child: Container(
                      width: 70.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

