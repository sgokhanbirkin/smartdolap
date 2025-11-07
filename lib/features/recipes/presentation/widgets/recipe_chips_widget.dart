import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Recipe chips widget displaying category, duration, calories, difficulty, and missing ingredients
class RecipeChipsWidget extends StatelessWidget {
  const RecipeChipsWidget({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSizes.spacingS,
    runSpacing: AppSizes.spacingS,
    children: <Widget>[
      if ((recipe.category ?? '').isNotEmpty)
        Chip(label: Text(recipe.category!)),
      if (recipe.durationMinutes != null)
        Chip(
          avatar: const Icon(Icons.timer, size: 18),
          label: Text(
            tr(
              'duration_minutes',
              namedArgs: <String, String>{
                'value': '${recipe.durationMinutes}',
              },
            ),
          ),
        ),
      if (recipe.calories != null)
        Chip(
          avatar: const Icon(
            Icons.local_fire_department,
            size: 18,
          ),
          label: Text(
            tr(
              'calories_kcal',
              namedArgs: <String, String>{
                'value': '${recipe.calories}',
              },
            ),
          ),
        ),
      if ((recipe.difficulty ?? '').isNotEmpty)
        Chip(
          avatar: const Icon(Icons.speed, size: 18),
          label: Text(
            tr(
              'difficulty_label',
              namedArgs: <String, String>{
                'value': recipe.difficulty!,
              },
            ),
          ),
        ),
      if (recipe.missingCount != null)
        Chip(
          avatar: Icon(
            recipe.missingCount! > 0 ? Icons.warning : Icons.check,
            size: 18,
          ),
          label: Text(
            recipe.missingCount! <= 0
                ? tr('all_ingredients')
                : tr(
                    'missing_n',
                    namedArgs: <String, String>{
                      'n': '${recipe.missingCount}',
                    },
                  ),
          ),
        ),
    ],
  );
}

