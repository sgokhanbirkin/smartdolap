import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Widget for selecting recipe category
class RecipeCategorySelectorWidget extends StatelessWidget {
  /// Constructor
  const RecipeCategorySelectorWidget({
    required this.selectedCategory,
    required this.onCategoryChanged,
    super.key,
  });

  /// Currently selected category
  final String selectedCategory;

  /// Callback when category changes
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: AppSizes.spacingS),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _CategoryChip(
            label: tr('suggestions'),
            category: 'suggestions',
            isSelected: selectedCategory == 'suggestions',
            onTap: () => onCategoryChanged('suggestions'),
            icon: Icons.lightbulb_outline,
          ),
          SizedBox(width: AppSizes.spacingXS),
          _CategoryChip(
            label: tr('favorites'),
            category: 'favorites',
            isSelected: selectedCategory == 'favorites',
            onTap: () => onCategoryChanged('favorites'),
            icon: Icons.favorite,
          ),
          SizedBox(width: AppSizes.spacingXS),
          _CategoryChip(
            label: tr('made_recipes'),
            category: 'made_recipes',
            isSelected: selectedCategory == 'made_recipes',
            onTap: () => onCategoryChanged('made_recipes'),
            icon: Icons.check_circle_outline,
          ),
          SizedBox(width: AppSizes.spacingXS),
          _CategoryChip(
            label: tr('shared_recipes'),
            category: 'shared_recipes',
            isSelected: selectedCategory == 'shared_recipes',
            onTap: () => onCategoryChanged('shared_recipes'),
            icon: Icons.share,
          ),
        ],
      ),
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...[
          Icon(icon, size: AppSizes.iconXS),
          SizedBox(width: AppSizes.spacingXS * 0.5),
        ],
        Text(label),
      ],
    ),
    selected: isSelected,
    onSelected: (_) => onTap(),
    selectedColor: Theme.of(context).colorScheme.primaryContainer,
    checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    labelStyle: TextStyle(
      color: isSelected
          ? Theme.of(context).colorScheme.onPrimaryContainer
          : Theme.of(context).colorScheme.onSurface,
      fontSize: AppSizes.textS,
    ),
  );
}

