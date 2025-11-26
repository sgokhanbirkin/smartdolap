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

      if (currentPreferences != null) {
        _selectedFoodIds = List<String>.from(currentPreferences.selectedFoodIds);
        _mealTypePreferences = currentPreferences.mealTypePreferences;
      }

      emit(
        FoodPreferencesState.loaded(
          allFoodPreferences: allFoodPreferences,
          selectedFoodIds: _selectedFoodIds,
          currentPreferences: currentPreferences,
        ),
      );
    } catch (e) {
      emit(FoodPreferencesState.error(e.toString()));
    }
  }

  /// Toggle food selection
  void toggleFoodSelection(String foodId) {
    state.maybeWhen(
      loaded: (List<FoodPreference> allFoodPreferences, List<String> selectedFoodIds, UserFoodPreferences? currentPreferences) {
        if (_selectedFoodIds.contains(foodId)) {
          _selectedFoodIds.remove(foodId);
        } else {
          _selectedFoodIds.add(foodId);
        }
        emit(
          FoodPreferencesState.loaded(
            allFoodPreferences: allFoodPreferences,
            selectedFoodIds: List<String>.from(_selectedFoodIds),
            currentPreferences: currentPreferences,
          ),
        );
      },
      orElse: () {},
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
    } catch (e) {
      emit(FoodPreferencesState.error(e.toString()));
    }
  }

  /// Get selected food IDs
  List<String> get selectedFoodIds => List<String>.from(_selectedFoodIds);

  /// Get meal type preferences
  MealTypePreferences get mealTypePreferences => _mealTypePreferences;
}

