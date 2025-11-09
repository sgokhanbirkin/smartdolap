import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/presentation/widgets/chip_group_widget.dart';

/// Preference controls widget
class PreferenceControlsWidget extends StatefulWidget {
  const PreferenceControlsWidget({
    required this.prefs,
    required this.onPrefsChanged,
    super.key,
  });

  final PromptPreferences prefs;
  final ValueChanged<PromptPreferences> onPrefsChanged;

  @override
  State<PreferenceControlsWidget> createState() =>
      _PreferenceControlsWidgetState();
}

class _PreferenceControlsWidgetState extends State<PreferenceControlsWidget> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.prefs.customNote);
  }

  @override
  void didUpdateWidget(PreferenceControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prefs.customNote != widget.prefs.customNote) {
      _noteController.text = widget.prefs.customNote;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleCustomAdd(String fieldKey, String value) {
    PromptPreferences updated;
    switch (fieldKey) {
      case 'diet':
        updated = widget.prefs.copyWith(
          customDiets: <String>[...widget.prefs.customDiets, value],
        );
        break;
      case 'cuisine':
        updated = widget.prefs.copyWith(
          customCuisines: <String>[...widget.prefs.customCuisines, value],
        );
        break;
      case 'tone':
        updated = widget.prefs.copyWith(
          customTones: <String>[...widget.prefs.customTones, value],
        );
        break;
      case 'goal':
        updated = widget.prefs.copyWith(
          customGoals: <String>[...widget.prefs.customGoals, value],
        );
        break;
      default:
        return;
    }
    widget.onPrefsChanged(updated);
  }

  void _handleCustomRemove(String fieldKey, String value) {
    PromptPreferences updated;
    switch (fieldKey) {
      case 'diet':
        updated = widget.prefs.copyWith(
          customDiets: widget.prefs.customDiets
              .where((String v) => v != value)
              .toList(),
        );
        break;
      case 'cuisine':
        updated = widget.prefs.copyWith(
          customCuisines: widget.prefs.customCuisines
              .where((String v) => v != value)
              .toList(),
        );
        break;
      case 'tone':
        updated = widget.prefs.copyWith(
          customTones: widget.prefs.customTones
              .where((String v) => v != value)
              .toList(),
        );
        break;
      case 'goal':
        updated = widget.prefs.copyWith(
          customGoals: widget.prefs.customGoals
              .where((String v) => v != value)
              .toList(),
        );
        break;
      default:
        return;
    }
    widget.onPrefsChanged(updated);
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            tr('profile_customize_title'),
            style: TextStyle(
              fontSize: AppSizes.textM,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          ChipGroupWidget(
            fieldKey: 'diet',
            title: tr('profile_diet_title'),
            hint: tr('profile_diet_hint'),
            options: const <String>[
              'dengeli',
              'vegan',
              'vejetaryen',
              'keto',
              'protein',
            ],
            customValues: widget.prefs.customDiets,
            selected: widget.prefs.dietStyle,
            onSelected: (String value) =>
                widget.onPrefsChanged(widget.prefs.copyWith(dietStyle: value)),
            onAddCustom: (String value) => _handleCustomAdd('diet', value),
            onRemoveCustom: (String value) =>
                _handleCustomRemove('diet', value),
          ),
          ChipGroupWidget(
            fieldKey: 'cuisine',
            title: tr('profile_cuisine_title'),
            hint: tr('profile_cuisine_hint'),
            options: const <String>[
              'Akdeniz',
              'Anadolu',
              'Asya',
              'Latin',
              'Nordic',
            ],
            customValues: widget.prefs.customCuisines,
            selected: widget.prefs.cuisineFocus,
            onSelected: (String value) => widget.onPrefsChanged(
              widget.prefs.copyWith(cuisineFocus: value),
            ),
            onAddCustom: (String value) => _handleCustomAdd('cuisine', value),
            onRemoveCustom: (String value) =>
                _handleCustomRemove('cuisine', value),
          ),
          ChipGroupWidget(
            fieldKey: 'tone',
            title: tr('profile_mood_title'),
            hint: tr('profile_mood_hint'),
            options: const <String>['enerjik', 'huzurlu', 'romantik', 'sporcu'],
            customValues: widget.prefs.customTones,
            selected: widget.prefs.tone,
            onSelected: (String value) =>
                widget.onPrefsChanged(widget.prefs.copyWith(tone: value)),
            onAddCustom: (String value) => _handleCustomAdd('tone', value),
            onRemoveCustom: (String value) =>
                _handleCustomRemove('tone', value),
          ),
          ChipGroupWidget(
            fieldKey: 'goal',
            title: tr('profile_goal_title'),
            hint: tr('profile_goal_hint'),
            options: const <String>['pratik', 'gourmet', 'budget', 'detox'],
            customValues: widget.prefs.customGoals,
            selected: widget.prefs.goal,
            onSelected: (String value) =>
                widget.onPrefsChanged(widget.prefs.copyWith(goal: value)),
            onAddCustom: (String value) => _handleCustomAdd('goal', value),
            onRemoveCustom: (String value) =>
                _handleCustomRemove('goal', value),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Text(tr('profile_servings')),
          SegmentedButton<int>(
            segments: <ButtonSegment<int>>[
              for (final int s in <int>[1, 2, 4, 6])
                ButtonSegment<int>(value: s, label: Text('$s')),
            ],
            selected: <int>{widget.prefs.servings},
            onSelectionChanged: (Set<int> selection) => widget.onPrefsChanged(
              widget.prefs.copyWith(servings: selection.first),
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Text(
            tr('profile_custom_note'),
            style: TextStyle(
              fontSize: AppSizes.textS,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSizes.spacingXS),
          Text(
            tr('profile_custom_note_hint'),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizes.spacingS),
          TextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 5,
            style: TextStyle(fontSize: AppSizes.textM),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.edit_note_outlined),
              hintText: tr('profile_custom_note_hint'),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
            ),
            onChanged: (String value) =>
                widget.onPrefsChanged(widget.prefs.copyWith(customNote: value)),
          ),
        ],
      ),
    ),
  );
}
