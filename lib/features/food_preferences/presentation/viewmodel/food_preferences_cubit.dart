import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/food_preference.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/meal_type_preferences.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/user_food_preferences.dart';
import 'package:smartdolap/features/food_preferences/domain/use_cases/get_all_food_preferences_usecase.dart';
import 'package:smartdolap/features/food_preferences/domain/use_cases/get_user_food_preferences_usecase.dart';
import 'package:smartdolap/features/food_preferences/domain/use_cases/save_user_food_preferences_usecase.dart';
import 'package:smartdolap/features/food_preferences/presentation/viewmodel/food_preferences_state.dart';

/// Food preferences cubit - manages food preferences onboarding state
class FoodPreferencesCubit extends Cubit<FoodPreferencesState> {
  /// Food preferences cubit constructor
  FoodPreferencesCubit({
    required this.getAllFoodPreferencesUseCase,
    required this.getUserFoodPreferencesUseCase,
    required this.saveUserFoodPreferencesUseCase,
  }) : super(const FoodPreferencesState.initial());

  final GetAllFoodPreferencesUseCase getAllFoodPreferencesUseCase;
  final GetUserFoodPreferencesUseCase getUserFoodPreferencesUseCase;
  final SaveUserFoodPreferencesUseCase saveUserFoodPreferencesUseCase;

  List<String> _selectedFoodIds = <String>[];
  MealTypePreferences _mealTypePreferences = const MealTypePreferences();

  /// Load food preferences
  Future<void> loadFoodPreferences(String userId) async {
    emit(const FoodPreferencesState.loading());
    try {
      final List<FoodPreference> allFoodPreferences =
          await getAllFoodPreferencesUseCase.call();
      final UserFoodPreferences? currentPreferences =
          await getUserFoodPreferencesUseCase.call(userId);

      // Debug: Print loaded preferences
      debugPrint(
        '[FoodPreferencesCubit] Loaded ${allFoodPreferences.length} food preferences',
      );
      for (final food in allFoodPreferences) {
        debugPrint(
          '[FoodPreferencesCubit] Food: ${food.id} - ${food.name} (${food.category})',
        );
      }

      if (currentPreferences != null) {
        _selectedFoodIds = List<String>.from(
          currentPreferences.selectedFoodIds,
        );
        _mealTypePreferences = currentPreferences.mealTypePreferences;
        debugPrint(
          '[FoodPreferencesCubit] Current preferences found: ${_selectedFoodIds.length} foods selected',
        );
      } else {
        debugPrint('[FoodPreferencesCubit] No current preferences found');
      }

      emit(
        FoodPreferencesState.loaded(
          allFoodPreferences: allFoodPreferences,
          selectedFoodIds: _selectedFoodIds,
          currentPreferences: currentPreferences,
        ),
      );
    } on Object catch (error) {
      debugPrint('[FoodPreferencesCubit] Error loading preferences: $error');
      emit(FoodPreferencesState.error(error.toString()));
    }
  }

  /// Toggle food selection
  void toggleFoodSelection(String foodId) {
    state.maybeWhen(
      loaded:
          (
            List<FoodPreference> allFoodPreferences,
            List<String> selectedFoodIds,
            UserFoodPreferences? currentPreferences,
          ) {
            if (_selectedFoodIds.contains(foodId)) {
              _selectedFoodIds.remove(foodId);
              debugPrint(
                '[FoodPreferencesCubit] Removed food: $foodId, total: ${_selectedFoodIds.length}',
              );
            } else {
              _selectedFoodIds.add(foodId);
              debugPrint(
                '[FoodPreferencesCubit] Added food: $foodId, total: ${_selectedFoodIds.length}',
              );
            }
            debugPrint('[FoodPreferencesCubit] Selected foods: $_selectedFoodIds');
            emit(
              FoodPreferencesState.loaded(
                allFoodPreferences: allFoodPreferences,
                selectedFoodIds: List<String>.from(_selectedFoodIds),
                currentPreferences: currentPreferences,
              ),
            );
          },
      orElse: () {
        debugPrint(
          '[FoodPreferencesCubit] toggleFoodSelection called but state is not loaded',
        );
      },
    );
  }

  /// Update meal type preferences
  void updateMealTypePreferences({
    List<String>? breakfast,
    List<String>? lunch,
    List<String>? dinner,
    List<String>? snack,
  }) {
    _mealTypePreferences = _mealTypePreferences.copyWith(
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snack: snack,
    );
  }

  /// Save food preferences
  Future<void> saveFoodPreferences({
    required String userId,
    required String householdId,
  }) async {
    emit(const FoodPreferencesState.saving());
    try {
      final UserFoodPreferences preferences = UserFoodPreferences(
        userId: userId,
        householdId: householdId,
        selectedFoodIds: _selectedFoodIds,
        mealTypePreferences: _mealTypePreferences,
        completedAt: DateTime.now(),
        isCompleted: true,
      );

      await saveUserFoodPreferencesUseCase.call(preferences);
      emit(const FoodPreferencesState.saved());
    } on Object catch (error) {
      emit(FoodPreferencesState.error(error.toString()));
    }
  }

  /// Get selected food IDs
  List<String> get selectedFoodIds => List<String>.from(_selectedFoodIds);

  /// Get meal type preferences
  MealTypePreferences get mealTypePreferences => _mealTypePreferences;
}
