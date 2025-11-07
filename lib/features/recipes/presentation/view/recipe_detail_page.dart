import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';

/// Recipe detail screen
class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({required this.recipe, super.key});

  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('recipes_title'))),
        body: EmptyState(messageKey: 'recipes_empty_message'),
      );
    }
    final Recipe data = recipe!;
    return Scaffold(
      appBar: AppBar(title: Text(data.title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HeroImage(imageUrl: data.imageUrl),
            SizedBox(height: AppSizes.verticalSpacingM),
            Wrap(
              spacing: AppSizes.spacingS,
              runSpacing: AppSizes.spacingS,
              children: <Widget>[
                if ((data.category ?? '').isNotEmpty)
                  Chip(label: Text(data.category!)),
                if (data.durationMinutes != null)
                  Chip(
                    avatar: const Icon(Icons.timer, size: 18),
                    label: Text(
                      tr(
                        'duration_minutes',
                        namedArgs: <String, String>{
                          'value': '${data.durationMinutes}',
                        },
                      ),
                    ),
                  ),
                if (data.calories != null)
                  Chip(
                    avatar: const Icon(Icons.local_fire_department, size: 18),
                    label: Text(
                      tr(
                        'calories_kcal',
                        namedArgs: <String, String>{
                          'value': '${data.calories}',
                        },
                      ),
                    ),
                  ),
                if ((data.difficulty ?? '').isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.speed, size: 18),
                    label: Text(
                      tr(
                        'difficulty_label',
                        namedArgs: <String, String>{
                          'value': data.difficulty!,
                        },
                      ),
                    ),
                  ),
                if (data.missingCount != null)
                  Chip(
                    avatar: Icon(
                      data.missingCount! > 0 ? Icons.warning : Icons.check,
                      size: 18,
                    ),
                    label: Text(
                      data.missingCount! <= 0
                          ? tr('all_ingredients')
                          : tr(
                              'missing_n',
                              namedArgs: <String, String>{
                                'n': '${data.missingCount}',
                              },
                            ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSizes.verticalSpacingL),
            Text(
              tr('ingredients_label'),
              style: TextStyle(
                fontSize: AppSizes.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingS),
            ...data.ingredients.map(
              (String item) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('• '),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: AppSizes.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingL),
            Text(
              tr('steps_label'),
              style: TextStyle(
                fontSize: AppSizes.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingS),
            ...data.steps.asMap().entries.map(
              (MapEntry<int, String> entry) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingS),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: AppSizes.radiusS,
                    child: Text('${entry.key + 1}'),
                  ),
                  title: Text(
                    entry.value,
                    style: TextStyle(fontSize: AppSizes.text),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Icon(Icons.restaurant, size: AppSizes.iconXL),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.restaurant, size: AppSizes.iconXL),
          ),
        ),
      ),
    );
  }
}
