import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Progress card widget showing ingredients and steps progress
class ProgressCardWidget extends StatelessWidget {
  const ProgressCardWidget({
    required this.ingredientProgress,
    required this.stepProgress,
    required this.collectedIngredientsCount,
    required this.totalIngredientsCount,
    required this.completedStepsCount,
    required this.totalStepsCount,
    super.key,
  });

  final double ingredientProgress;
  final double stepProgress;
  final int collectedIngredientsCount;
  final int totalIngredientsCount;
  final int completedStepsCount;
  final int totalStepsCount;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tr('recipe_progress'),
            style: TextStyle(
              fontSize: AppSizes.textM,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingS),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tr('ingredients_label'),
                      style: TextStyle(fontSize: AppSizes.textS),
                    ),
                    SizedBox(height: AppSizes.spacingXS),
                    LinearProgressIndicator(
                      value: ingredientProgress,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    SizedBox(height: AppSizes.spacingXS),
                    Text(
                      '$collectedIngredientsCount/$totalIngredientsCount',
                      style: TextStyle(fontSize: AppSizes.textXS),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tr('steps_label'),
                      style: TextStyle(fontSize: AppSizes.textS),
                    ),
                    SizedBox(height: AppSizes.spacingXS),
                    LinearProgressIndicator(
                      value: stepProgress,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    SizedBox(height: AppSizes.spacingXS),
                    Text(
                      '$completedStepsCount/$totalStepsCount',
                      style: TextStyle(fontSize: AppSizes.textXS),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

