import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';

/// Widget that displays the category detection status
/// (loading, suggested, or empty)
class CategoryStatusChipWidget extends StatelessWidget {
  /// Creates a category status chip widget
  const CategoryStatusChipWidget({
    required this.isCategorizing,
    this.suggestedCategory,
    super.key,
  });

  /// Whether AI is currently categorizing the item
  final bool isCategorizing;

  /// The suggested category from AI (if available)
  final String? suggestedCategory;

  @override
  Widget build(BuildContext context) {
    if (isCategorizing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: AppSizes.iconXS,
            height: AppSizes.iconXS,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: AppSizes.spacingXS),
          Text(
            tr('pantry_category_detecting'),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    if (suggestedCategory != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.auto_awesome,
            size: AppSizes.iconS,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: AppSizes.spacingXS),
          Text(
            tr(
              'pantry_category_suggested',
              namedArgs: <String, String>{
                'category': PantryCategoryHelper.getLocalizedCategoryName(
                  suggestedCategory!,
                ),
              },
            ),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
