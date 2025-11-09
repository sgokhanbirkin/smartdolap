import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/category_group_widget.dart';

/// Widget for displaying ingredients selection section
class IngredientsSelectionSectionWidget extends StatelessWidget {
  /// Creates an ingredients selection section widget
  const IngredientsSelectionSectionWidget({
    required this.items,
    required this.selectedIngredients,
    required this.expandedCategories,
    required this.onToggleCategory,
    required this.onToggleIngredient,
    required this.onAddIngredient,
    super.key,
  });

  /// List of pantry items
  final List<PantryItem> items;

  /// Set of selected ingredient names
  final Set<String> selectedIngredients;

  /// Map of expanded categories
  final Map<String, bool> expandedCategories;

  /// Callback when category is toggled
  final ValueChanged<String> onToggleCategory;

  /// Callback when ingredient is toggled
  final ValueChanged<String> onToggleIngredient;

  /// Callback when add ingredient button is pressed
  final VoidCallback onAddIngredient;

  Map<String, List<PantryItem>> _groupByCategory(List<PantryItem> items) {
    final Map<String, List<PantryItem>> grouped = <String, List<PantryItem>>{};
    for (final PantryItem item in items) {
      final String category = PantryCategoryHelper.normalize(item.category);
      grouped.putIfAbsent(category, () => <PantryItem>[]).add(item);
    }
    // Sort categories
    final List<String> sortedCategories = grouped.keys.toList()
      ..sort(
        (String a, String b) => PantryCategoryHelper.categories
            .indexOf(a)
            .compareTo(PantryCategoryHelper.categories.indexOf(b)),
      );
    final Map<String, List<PantryItem>> sorted = <String, List<PantryItem>>{};
    for (final String category in sortedCategories) {
      sorted[category] = grouped[category]!;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<PantryItem>> grouped = _groupByCategory(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              tr('select_ingredients'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: tr('add_ingredient'),
              onPressed: onAddIngredient,
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingS),
        ...grouped.entries.map(
          (MapEntry<String, List<PantryItem>> entry) =>
              CategoryGroupWidget(
            category: entry.key,
            items: entry.value,
            selectedIngredients: selectedIngredients,
            isExpanded: expandedCategories[entry.key] ?? true,
            onToggleCategory: () => onToggleCategory(entry.key),
            onToggleIngredient: onToggleIngredient,
          ),
        ),
      ],
    );
  }
}

