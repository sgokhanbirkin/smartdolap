import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/category_colors.dart';

/// Widget for category filter chips
class CategoryFilterChipsWidget extends StatelessWidget {
  /// Creates a category filter chips widget
  const CategoryFilterChipsWidget({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  /// Available categories
  final List<String> categories;

  /// Currently selected category (null means all)
  final String? selectedCategory;

  /// Callback when category is selected
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppSizes.buttonHeight,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      children: <Widget>[
        FilterChip(
          label: Text(tr('all_categories')),
          selected: selectedCategory == null,
          onSelected: (bool selected) {
            if (selected) {
              onCategorySelected(null);
            }
          },
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
          labelStyle: TextStyle(
            fontSize: AppSizes.textS,
            fontWeight: selectedCategory == null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        SizedBox(width: AppSizes.spacingS),
        ...categories.map<Widget>(
          (String cat) => Padding(
            padding: EdgeInsets.only(right: AppSizes.spacingS),
            child: FilterChip(
              label: Text(cat),
              selected: selectedCategory == cat,
              onSelected: (bool selected) {
                onCategorySelected(selected ? cat : null);
              },
              selectedColor: selectedCategory == cat
                  ? CategoryColors.getCategoryBadgeColor(cat)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              checkmarkColor: CategoryColors.getCategoryBadgeTextColor(cat),
              labelStyle: TextStyle(
                fontSize: AppSizes.textS,
                fontWeight: selectedCategory == cat ? FontWeight.w600 : FontWeight.normal,
                color: selectedCategory == cat
                    ? CategoryColors.getCategoryBadgeTextColor(cat)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

