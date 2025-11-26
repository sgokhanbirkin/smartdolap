import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Widget for meal selection dropdown
class MealSelectorWidget extends StatelessWidget {
  /// Creates a meal selector widget
  const MealSelectorWidget({
    required this.selectedMeal,
    required this.onMealChanged,
    super.key,
  });

  /// Currently selected meal key
  final String selectedMeal;

  /// Callback when meal selection changes
  final ValueChanged<String> onMealChanged;

  /// Available meal keys
  static const List<String> mealKeys = <String>[
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tr('meal'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSizes.spacingS),
        DropdownButton<String>(
          value: selectedMeal,
          isExpanded: true,
          items: mealKeys
              .map(
                (String key) => DropdownMenuItem<String>(
                  value: key,
                  child: Text(tr(key)),
                ),
              )
              .toList(),
          onChanged: (String? value) {
            if (value != null) {
              onMealChanged(value);
            }
          },
        ),
      ],
    );
}
