import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/food_preference.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/user_food_preferences.dart';

part 'food_preferences_state.freezed.dart';

/// Food preferences state - represents the state of food preferences onboarding
@freezed
class FoodPreferencesState with _$FoodPreferencesState {
  /// Initial state
  const factory FoodPreferencesState.initial() = _Initial;

  /// Loading state
  const factory FoodPreferencesState.loading() = _Loading;

  /// Loaded state with food preferences
  const factory FoodPreferencesState.loaded({
    required List<FoodPreference> allFoodPreferences,
    required List<String> selectedFoodIds,
    required UserFoodPreferences? currentPreferences,
  }) = _Loaded;

  /// Saving state
  const factory FoodPreferencesState.saving() = _Saving;

  /// Saved state
  const factory FoodPreferencesState.saved() = _Saved;

  /// Error state
  const factory FoodPreferencesState.error(String message) = _Error;
}

