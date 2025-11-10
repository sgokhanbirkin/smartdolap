import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/presentation/widgets/chip_group_widget.dart';

/// Advanced recipe settings page with detailed filters
class RecipeAdvancedSettingsPage extends StatefulWidget {
  const RecipeAdvancedSettingsPage({
    required this.initialPrefs,
    required this.onSave,
    super.key,
  });

  final PromptPreferences initialPrefs;
  final ValueChanged<PromptPreferences> onSave;

  @override
  State<RecipeAdvancedSettingsPage> createState() =>
      _RecipeAdvancedSettingsPageState();
}

class _RecipeAdvancedSettingsPageState
    extends State<RecipeAdvancedSettingsPage> {
  late PromptPreferences _prefs;
  final TextEditingController _calorieMinController = TextEditingController();
  final TextEditingController _calorieMaxController = TextEditingController();
  final TextEditingController _proteinMinController = TextEditingController();
  final TextEditingController _fiberMinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefs = widget.initialPrefs;
    _calorieMinController.text =
        _prefs.calorieRangeMin > 0 ? _prefs.calorieRangeMin.toString() : '';
    _calorieMaxController.text =
        _prefs.calorieRangeMax > 0 ? _prefs.calorieRangeMax.toString() : '';
    _proteinMinController.text =
        _prefs.proteinMin > 0 ? _prefs.proteinMin.toString() : '';
    _fiberMinController.text =
        _prefs.fiberMin > 0 ? _prefs.fiberMin.toString() : '';
  }

  @override
  void dispose() {
    _calorieMinController.dispose();
    _calorieMaxController.dispose();
    _proteinMinController.dispose();
    _fiberMinController.dispose();
    super.dispose();
  }

  void _updatePrefs(PromptPreferences newPrefs) {
    setState(() => _prefs = newPrefs);
  }

  void _saveAndPop() {
    // Parse numeric fields
    final int calorieMin = int.tryParse(_calorieMinController.text) ?? 0;
    final int calorieMax = int.tryParse(_calorieMaxController.text) ?? 0;
    final int proteinMin = int.tryParse(_proteinMinController.text) ?? 0;
    final int fiberMin = int.tryParse(_fiberMinController.text) ?? 0;

    final PromptPreferences finalPrefs = _prefs.copyWith(
      calorieRangeMin: calorieMin,
      calorieRangeMax: calorieMax,
      proteinMin: proteinMin,
      fiberMin: fiberMin,
    );

    widget.onSave(finalPrefs);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('profile_advanced_settings_title')),
      actions: <Widget>[
        TextButton(
          onPressed: _saveAndPop,
          child: Text(
            tr('save'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Basic settings (already in simple view)
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr('profile_basic_settings'),
                    style: TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
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
                      'paleo',
                      'low-carb',
                    ],
                    customValues: _prefs.customDiets,
                    selected: _prefs.dietStyle,
                    onSelected: (String value) =>
                        _updatePrefs(_prefs.copyWith(dietStyle: value)),
                    onAddCustom: (String value) {
                      _updatePrefs(_prefs.copyWith(
                        customDiets: <String>[..._prefs.customDiets, value],
                      ));
                    },
                    onRemoveCustom: (String value) {
                      _updatePrefs(_prefs.copyWith(
                        customDiets: _prefs.customDiets
                            .where((String v) => v != value)
                            .toList(),
                      ));
                    },
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
                      'İtalyan',
                      'Fransız',
                      'Japon',
                      'Meksika',
                    ],
                    customValues: _prefs.customCuisines,
                    selected: _prefs.cuisineFocus,
                    onSelected: (String value) => _updatePrefs(
                      _prefs.copyWith(cuisineFocus: value),
                    ),
                    onAddCustom: (String value) {
                      _updatePrefs(_prefs.copyWith(
                        customCuisines: <String>[..._prefs.customCuisines, value],
                      ));
                    },
                    onRemoveCustom: (String value) {
                      _updatePrefs(_prefs.copyWith(
                        customCuisines: _prefs.customCuisines
                            .where((String v) => v != value)
                            .toList(),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          // Cooking preferences
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr('profile_cooking_preferences'),
                    style: TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingM),
                  // Cooking time
                  Text(
                    tr('profile_cooking_time'),
                    style: TextStyle(
                      fontSize: AppSizes.textM,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingS),
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'hızlı',
                        label: Text(tr('profile_cooking_time_fast')),
                      ),
                      ButtonSegment<String>(
                        value: 'orta',
                        label: Text(tr('profile_cooking_time_medium')),
                      ),
                      ButtonSegment<String>(
                        value: 'uzun',
                        label: Text(tr('profile_cooking_time_long')),
                      ),
                    ],
                    selected: <String>{_prefs.cookingTime},
                    onSelectionChanged: (Set<String> selection) =>
                        _updatePrefs(_prefs.copyWith(
                          cookingTime: selection.first,
                        )),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingM),
                  // Difficulty
                  Text(
                    tr('profile_difficulty'),
                    style: TextStyle(
                      fontSize: AppSizes.textM,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingS),
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'kolay',
                        label: Text(tr('profile_difficulty_easy')),
                      ),
                      ButtonSegment<String>(
                        value: 'orta',
                        label: Text(tr('profile_difficulty_medium')),
                      ),
                      ButtonSegment<String>(
                        value: 'zor',
                        label: Text(tr('profile_difficulty_hard')),
                      ),
                    ],
                    selected: <String>{_prefs.difficulty},
                    onSelectionChanged: (Set<String> selection) =>
                        _updatePrefs(_prefs.copyWith(
                          difficulty: selection.first,
                        )),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          // Nutritional filters
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr('profile_nutritional_filters'),
                    style: TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingM),
                  // Calorie range
                  Text(
                    tr('profile_calorie_range'),
                    style: TextStyle(
                      fontSize: AppSizes.textM,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingS),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _calorieMinController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: tr('profile_calorie_min'),
                            hintText: '0',
                            prefixIcon: const Icon(Icons.trending_down),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingM),
                      Text(
                        '-',
                        style: TextStyle(fontSize: AppSizes.textL),
                      ),
                      SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: TextField(
                          controller: _calorieMaxController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: tr('profile_calorie_max'),
                            hintText: '0',
                            prefixIcon: const Icon(Icons.trending_up),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.verticalSpacingM),
                  // Protein minimum
                  TextField(
                    controller: _proteinMinController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: tr('profile_protein_min'),
                      hintText: '0',
                      prefixIcon: const Icon(Icons.fitness_center),
                      suffixText: tr('profile_grams'),
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingM),
                  // Fiber minimum
                  TextField(
                    controller: _fiberMinController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: tr('profile_fiber_min'),
                      hintText: '0',
                      prefixIcon: const Icon(Icons.eco),
                      suffixText: tr('profile_grams'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          // Special diets
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr('profile_special_diets'),
                    style: TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingM),
                  Wrap(
                    spacing: AppSizes.spacingS,
                    runSpacing: AppSizes.spacingS,
                    children: <String>[
                      'gluten-free',
                      'laktoz-free',
                      'şeker-free',
                      'tuz-free',
                      'fındık-free',
                    ].map<Widget>(
                      (String diet) => FilterChip(
                        label: Text(diet),
                        selected: _prefs.specialDiets.contains(diet),
                        onSelected: (bool selected) {
                          if (selected) {
                            _updatePrefs(_prefs.copyWith(
                              specialDiets: <String>[..._prefs.specialDiets, diet],
                            ));
                          } else {
                            _updatePrefs(_prefs.copyWith(
                              specialDiets: _prefs.specialDiets
                                  .where((String d) => d != diet)
                                  .toList(),
                            ));
                          }
                        },
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          // Seasonal preference
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr('profile_seasonal_preference'),
                    style: TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingM),
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: '',
                        label: Text(tr('profile_season_none')),
                      ),
                      ButtonSegment<String>(
                        value: 'kış',
                        label: Text(tr('profile_season_winter')),
                      ),
                      ButtonSegment<String>(
                        value: 'yaz',
                        label: Text(tr('profile_season_summer')),
                      ),
                      ButtonSegment<String>(
                        value: 'ilkbahar',
                        label: Text(tr('profile_season_spring')),
                      ),
                      ButtonSegment<String>(
                        value: 'sonbahar',
                        label: Text(tr('profile_season_fall')),
                      ),
                    ],
                    selected: <String>{_prefs.seasonalPreference},
                    onSelectionChanged: (Set<String> selection) =>
                        _updatePrefs(_prefs.copyWith(
                          seasonalPreference: selection.first,
                        )),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          // Preferred meal types
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr('profile_preferred_meal_types'),
                    style: TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingM),
                  Wrap(
                    spacing: AppSizes.spacingS,
                    runSpacing: AppSizes.spacingS,
                    children: <String>[
                      'breakfast',
                      'lunch',
                      'dinner',
                      'snack',
                    ].map<Widget>(
                      (String mealType) => FilterChip(
                        label: Text(tr('profile_meal_$mealType')),
                        selected: _prefs.preferredMealTypes.contains(mealType),
                        onSelected: (bool selected) {
                          if (selected) {
                            _updatePrefs(_prefs.copyWith(
                              preferredMealTypes: <String>[..._prefs.preferredMealTypes, mealType],
                            ));
                          } else {
                            _updatePrefs(_prefs.copyWith(
                              preferredMealTypes: _prefs.preferredMealTypes
                                  .where((String m) => m != mealType)
                                  .toList(),
                            ));
                          }
                        },
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          // Tone and Goal (from basic settings)
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ChipGroupWidget(
                    fieldKey: 'tone',
                    title: tr('profile_mood_title'),
                    hint: tr('profile_mood_hint'),
                    options: const <String>[
                      'enerjik',
                      'huzurlu',
                      'romantik',
                      'sporcu',
                      'rahatlatıcı',
                      'eğlenceli',
                    ],
                    customValues: _prefs.customTones,
                    selected: _prefs.tone,
                    onSelected: (String value) =>
                        _updatePrefs(_prefs.copyWith(tone: value)),
                    onAddCustom: (String value) {
                      _updatePrefs(_prefs.copyWith(
                        customTones: <String>[..._prefs.customTones, value],
                      ));
                    },
                    onRemoveCustom: (String value) {
                      _updatePrefs(_prefs.copyWith(
                        customTones: _prefs.customTones
                            .where((String v) => v != value)
                            .toList(),
                      ));
                    },
                  ),
                  ChipGroupWidget(
                    fieldKey: 'goal',
                    title: tr('profile_goal_title'),
                    hint: tr('profile_goal_hint'),
                    options: const <String>[
                      'pratik',
                      'gourmet',
                      'budget',
                      'detox',
                      'enerji',
                      'sağlık',
                    ],
                    customValues: _prefs.customGoals,
                    selected: _prefs.goal,
                    onSelected: (String value) =>
                        _updatePrefs(_prefs.copyWith(goal: value)),
                    onAddCustom: (String value) {
                      _updatePrefs(_prefs.copyWith(
                        customGoals: <String>[..._prefs.customGoals, value],
                      ));
                    },
                    onRemoveCustom: (String value) {
                      _updatePrefs(_prefs.copyWith(
                        customGoals: _prefs.customGoals
                            .where((String v) => v != value)
                            .toList(),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingXXL),
        ],
      ),
    ),
  );
}

