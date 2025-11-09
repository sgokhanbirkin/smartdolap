import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/category_colors.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Widget for displaying a category group with expandable items
class CategoryGroupWidget extends StatelessWidget {
  /// Creates a category group widget
  const CategoryGroupWidget({
    required this.category,
    required this.items,
    required this.selectedIngredients,
    required this.isExpanded,
    required this.onToggleCategory,
    required this.onToggleIngredient,
    super.key,
  });

  /// Category name
  final String category;

  /// Items in this category
  final List<PantryItem> items;

  /// Set of selected ingredient names
  final Set<String> selectedIngredients;

  /// Whether the category is expanded
  final bool isExpanded;

  /// Callback when category is toggled
  final VoidCallback onToggleCategory;

  /// Callback when ingredient is toggled
  final ValueChanged<String> onToggleIngredient;

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = CategoryColors.getCategoryColor(category);
    final Color categoryIconColor =
        CategoryColors.getCategoryIconColor(category);
    final int selectedCount = items
        .where((PantryItem item) => selectedIngredients.contains(item.name))
        .length;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: onToggleCategory,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingS,
              ),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    PantryCategoryHelper.iconFor(category),
                    color: categoryIconColor,
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        fontWeight: FontWeight.w600,
                        color: categoryIconColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingS,
                      vertical: AppSizes.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                    child: Text(
                      '$selectedCount/${items.length}',
                      style: TextStyle(
                        fontSize: AppSizes.textXS,
                        fontWeight: FontWeight.bold,
                        color: categoryIconColor,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: categoryIconColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            SizedBox(height: AppSizes.spacingS),
            Wrap(
              spacing: AppSizes.spacingS,
              runSpacing: AppSizes.spacingS,
              children: items
                  .map(
                    (PantryItem item) => FilterChip(
                      label: Text(item.name),
                      selected: selectedIngredients.contains(item.name),
                      onSelected: (bool selected) =>
                          onToggleIngredient(item.name),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

