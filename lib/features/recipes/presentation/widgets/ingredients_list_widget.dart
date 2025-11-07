import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Ingredients list widget with checkboxes
class IngredientsListWidget extends StatelessWidget {
  const IngredientsListWidget({
    required this.ingredients,
    required this.collectedIngredients,
    required this.onIngredientToggled,
    super.key,
  });

  final List<String> ingredients;
  final Set<int> collectedIngredients;
  final ValueChanged<int> onIngredientToggled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        tr('ingredients_label'),
        style: TextStyle(
          fontSize: AppSizes.textL,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: AppSizes.verticalSpacingS),
      ...ingredients.asMap().entries.map(
        (MapEntry<int, String> entry) => CheckboxListTile(
          value: collectedIngredients.contains(entry.key),
          onChanged: (bool? value) {
            if (value != null) {
              onIngredientToggled(entry.key);
            }
          },
          title: Text(
            entry.value,
            style: TextStyle(
              fontSize: AppSizes.text,
              decoration: collectedIngredients.contains(entry.key)
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: collectedIngredients.contains(entry.key)
              ? Text(
                  tr('ingredient_collected'),
                  style: TextStyle(
                    fontSize: AppSizes.textXS,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
        ),
      ),
    ],
  );
}

