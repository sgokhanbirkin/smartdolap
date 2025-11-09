import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';

/// Dialog widget for selecting an ingredient from camera-detected ingredients
class CameraIngredientDialogWidget extends StatelessWidget {
  /// Creates a camera ingredient dialog widget
  const CameraIngredientDialogWidget({required this.ingredients, super.key});

  /// List of detected ingredients from camera
  final List<Ingredient> ingredients;

  /// Shows the dialog and returns the selected ingredient
  static Future<Ingredient?> show(
    BuildContext context,
    List<Ingredient> ingredients,
  ) async => showDialog<Ingredient>(
    context: context,
    builder: (BuildContext context) =>
        CameraIngredientDialogWidget(ingredients: ingredients),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(tr('select_ingredient')),
    content: SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: ingredients.length,
        itemBuilder: (BuildContext context, int index) {
          final Ingredient ingredient = ingredients[index];
          return ListTile(
            title: Text(ingredient.name),
            subtitle: Text('${ingredient.quantity} ${ingredient.unit}'),
            onTap: () => Navigator.of(context).pop(ingredient),
          );
        },
      ),
    ),
  );
}
