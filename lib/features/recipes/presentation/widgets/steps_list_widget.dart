// ignore_for_file: join_return_with_assignment
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_step.dart';

/// Steps list widget with checkboxes and detailed information
class StepsListWidget extends StatelessWidget {
  const StepsListWidget({
    required this.steps,
    required this.completedSteps,
    required this.onStepToggled,
    super.key,
  });

  final List<RecipeStep> steps;
  final Set<int> completedSteps;
  final ValueChanged<int> onStepToggled;

  /// Get step type icon
  IconData _getStepTypeIcon(String? stepType) {
    switch (stepType?.toLowerCase()) {
      case 'prep':
        return Icons.restaurant_menu;
      case 'cook':
        return Icons.local_fire_department;
      case 'bake':
        return Icons.cake;
      case 'rest':
        return Icons.timer_outlined;
      case 'serve':
        return Icons.restaurant;
      default:
        return Icons.check_circle_outline;
    }
  }

  /// Get step type label
  String _getStepTypeLabel(String? stepType) {
    if (stepType == null) {
      return '';
    }
    final String key = 'step_type_$stepType';
    final String translated = tr(key);
    // If translation key is missing, easy_localization returns the key itself.
    return translated == key ? stepType : translated;
  }

  /// Normalize step description for legacy/LLM formatted strings
  String _normalizeDescription(String description) {
    String text = description.trim();

    // Remove leading braces
    while (text.startsWith('{')) {
      text = text.substring(1).trim();
    }

    // Strip leading "description:" key if present
    text = text.replaceFirst(
      RegExp(r'^description\s*:?\s*', caseSensitive: false),
      '',
    );

    // Remove wrapping quotes and trailing braces
    if (text.endsWith('}')) {
      text = text.substring(0, text.length - 1).trim();
    }
    if (text.startsWith('"') && text.endsWith('"') && text.length >= 2) {
      text = text.substring(1, text.length - 1);
    }

    // Remove any stray quotes
    text = text.replaceAll('"', '').trim();

    return text;
  }

  @override
  Widget build(BuildContext context) {
    // Normalize and filter steps for legacy/LLM formatted content
    final List<RecipeStep> normalizedSteps = steps
        .where((RecipeStep step) {
          final String d = step.description.trim().toLowerCase();
          if (d.isEmpty) {
            return false;
          }
          if (d.startsWith('durationminutes:') ||
              d.startsWith('steptype:') ||
              d.startsWith('temperature:')) {
            return false;
          }
          return true;
        })
        .map(
          (RecipeStep step) => step.copyWith(
            description: _normalizeDescription(step.description),
          ),
        )
        .toList();

    return Column(
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
        ...normalizedSteps.asMap().entries.map((
          MapEntry<int, RecipeStep> entry,
        ) {
          final RecipeStep step = entry.value;
          final bool isCompleted = completedSteps.contains(entry.key);
          final bool isTablet = context.isTablet;

          return Card(
            margin: EdgeInsets.only(bottom: AppSizes.spacingS),
            elevation: isCompleted ? 0 : 1,
            color: isCompleted
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : null,
            child: ListTile(
              contentPadding: EdgeInsets.all(AppSizes.spacingS),
              leading: CircleAvatar(
                radius: isTablet ? 24.r : 20.r,
                backgroundColor: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  '${entry.key + 1}',
                  style: TextStyle(
                    fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(
                step.description,
                style: TextStyle(
                  fontSize: isTablet ? AppSizes.textM : AppSizes.text,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: AppSizes.spacingXS),
                  // Badges row
                  Wrap(
                    spacing: AppSizes.spacingXS,
                    runSpacing: AppSizes.spacingXS,
                    children: <Widget>[
                      // Duration badge
                      if (step.durationMinutes != null)
                        Chip(
                          avatar: Icon(
                            Icons.timer_outlined,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            '${step.durationMinutes} ${tr('minutes')}',
                            style: TextStyle(fontSize: AppSizes.textXS),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                        ),
                      // Step type badge
                      if (step.stepType != null)
                        Chip(
                          avatar: Icon(
                            _getStepTypeIcon(step.stepType),
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          label: Text(
                            _getStepTypeLabel(step.stepType),
                            style: TextStyle(fontSize: AppSizes.textXS),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                        ),
                      // Temperature badge
                      if (step.temperature != null)
                        Chip(
                          avatar: Icon(
                            Icons.thermostat,
                            size: 14.sp,
                            color: Colors.red,
                          ),
                          label: Text(
                            '${step.temperature}°C',
                            style: TextStyle(fontSize: AppSizes.textXS),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                        ),
                    ],
                  ),
                  // Tips
                  if (step.tips != null && step.tips!.isNotEmpty) ...<Widget>[
                    SizedBox(height: AppSizes.spacingXS),
                    Container(
                      padding: EdgeInsets.all(AppSizes.spacingXS),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16.sp,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          SizedBox(width: AppSizes.spacingXS),
                          Expanded(
                            child: Text(
                              step.tips!,
                              style: TextStyle(
                                fontSize: AppSizes.textXS,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Completed status
                  if (isCompleted) ...<Widget>[
                    SizedBox(height: AppSizes.spacingXS),
                    Text(
                      tr('step_completed'),
                      style: TextStyle(
                        fontSize: AppSizes.textXS,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Checkbox(
                value: isCompleted,
                onChanged: (bool? value) {
                  if (value != null) {
                    onStepToggled(entry.key);
                  }
                },
              ),
              onTap: () => onStepToggled(entry.key),
            ),
          );
        }),
      ],
    );
  }
}
