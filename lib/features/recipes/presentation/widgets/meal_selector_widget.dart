import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Widget for selecting meal type in suggestions category
class MealSelectorWidget extends StatelessWidget {
  /// Constructor
  const MealSelectorWidget({
    required this.selectedMeal,
    required this.onMealChanged,
    super.key,
  });

  /// Currently selected meal
  final String? selectedMeal;

  /// Callback when meal changes
  final ValueChanged<String?> onMealChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: AppSizes.spacingXS),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _MealChip(
            label: tr('all'),
            meal: null,
            isSelected: selectedMeal == null,
            onTap: () => onMealChanged(null),
          ),
          SizedBox(width: AppSizes.spacingXS),
          _MealChip(
            label: tr('breakfast'),
            meal: 'breakfast',
            isSelected: selectedMeal == 'breakfast',
            onTap: () => onMealChanged('breakfast'),
            icon: Icons.wb_sunny_outlined,
          ),
          SizedBox(width: AppSizes.spacingXS),
          _MealChip(
            label: tr('lunch'),
            meal: 'lunch',
            isSelected: selectedMeal == 'lunch',
            onTap: () => onMealChanged('lunch'),
            icon: Icons.restaurant_outlined,
          ),
          SizedBox(width: AppSizes.spacingXS),
          _MealChip(
            label: tr('dinner'),
            meal: 'dinner',
            isSelected: selectedMeal == 'dinner',
            onTap: () => onMealChanged('dinner'),
            icon: Icons.dinner_dining_outlined,
          ),
          SizedBox(width: AppSizes.spacingXS),
          _MealChip(
            label: tr('snack'),
            meal: 'snack',
            isSelected: selectedMeal == 'snack',
            onTap: () => onMealChanged('snack'),
            icon: Icons.cookie_outlined,
          ),
        ],
      ),
    ),
  );
}

class _MealChip extends StatelessWidget {
  const _MealChip({
    required this.label,
    required this.meal,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final String? meal;
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
    onSelected: (bool _) => onTap(),
    selectedColor: Theme.of(context).colorScheme.secondaryContainer,
    checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
    labelStyle: TextStyle(
      color: isSelected
          ? Theme.of(context).colorScheme.onSecondaryContainer
          : Theme.of(context).colorScheme.onSurface,
      fontSize: AppSizes.textXS,
    ),
  );
}

