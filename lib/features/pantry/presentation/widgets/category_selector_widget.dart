import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/category_status_chip_widget.dart';

/// Widget for selecting category with AI suggestions
class CategorySelectorWidget extends StatelessWidget {
  /// Creates a category selector widget
  const CategorySelectorWidget({
    required this.selectedCategory,
    required this.isCategorizing,
    required this.onCategorySelected,
    this.suggestedCategory,
    super.key,
  });

  /// Currently selected category
  final String? selectedCategory;

  /// Whether AI is categorizing
  final bool isCategorizing;

  /// Suggested category from AI
  final String? suggestedCategory;

  /// Callback when category is selected
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tr('pantry_category_title'),
            style: TextStyle(
              fontSize: AppSizes.textS,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSizes.spacingXS),
          Text(
            tr('pantry_category_hint'),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (isCategorizing || suggestedCategory != null)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.spacingS),
              child: CategoryStatusChipWidget(
                isCategorizing: isCategorizing,
                suggestedCategory: suggestedCategory,
              ),
            ),
          if (selectedCategory != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onCategorySelected(null),
                icon: const Icon(Icons.close, size: 16),
                label: Text(tr('pantry_category_clear')),
              ),
            ),
          SizedBox(height: AppSizes.spacingM),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool twoColumns = constraints.maxWidth > 380;
                  final double itemWidth = twoColumns
                      ? (constraints.maxWidth - AppSizes.spacingS) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: AppSizes.spacingS,
                    runSpacing: AppSizes.spacingS,
                    children: PantryCategoryHelper.categories.map((String cat) {
                      final bool selected = selectedCategory == cat;
                      final Widget chip = ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizes.spacingXS,
                          horizontal: AppSizes.spacingS,
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              PantryCategoryHelper.iconFor(cat),
                              size: AppSizes.iconXS,
                              color: selected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: AppSizes.spacingXS),
                            Flexible(
                              child: Text(
                                PantryCategoryHelper.getLocalizedCategoryName(
                                  cat,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        selected: selected,
                        onSelected: (bool value) =>
                            onCategorySelected(value ? cat : null),
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          fontSize: AppSizes.textXS,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      );
                      return twoColumns
                          ? SizedBox(width: itemWidth, child: chip)
                          : chip;
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
