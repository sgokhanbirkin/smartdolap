import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Steps list widget with checkboxes
class StepsListWidget extends StatelessWidget {
  const StepsListWidget({
    required this.steps,
    required this.completedSteps,
    required this.onStepToggled,
    super.key,
  });

  final List<String> steps;
  final Set<int> completedSteps;
  final ValueChanged<int> onStepToggled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        tr('steps_label'),
        style: TextStyle(
          fontSize: AppSizes.textL,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: AppSizes.verticalSpacingS),
      ...steps.asMap().entries.map(
        (MapEntry<int, String> entry) => ListTile(
          leading: CircleAvatar(
            radius: AppSizes.radiusS,
            backgroundColor: completedSteps.contains(entry.key)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '${entry.key + 1}',
              style: TextStyle(
                color: completedSteps.contains(entry.key)
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          title: Text(
            entry.value,
            style: TextStyle(
              fontSize: AppSizes.text,
              decoration: completedSteps.contains(entry.key)
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: completedSteps.contains(entry.key)
              ? Text(
                  tr('step_completed'),
                  style: TextStyle(
                    fontSize: AppSizes.textXS,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
          trailing: Checkbox(
            value: completedSteps.contains(entry.key),
            onChanged: (bool? value) {
              if (value != null) {
                onStepToggled(entry.key);
              }
            },
          ),
          onTap: () => onStepToggled(entry.key),
        ),
      ),
    ],
  );
}

