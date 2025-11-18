import 'package:smartdolap/features/food_preferences/domain/entities/user_food_preferences.dart';
import 'package:smartdolap/features/food_preferences/domain/repositories/i_food_preference_repository.dart';

/// Use case for saving user food preferences
class SaveUserFoodPreferencesUseCase {
  /// Save user food preferences use case constructor
  SaveUserFoodPreferencesUseCase(this._repository);

  final IFoodPreferenceRepository _repository;

  /// Execute saving user food preferences
  Future<void> call(UserFoodPreferences preferences) async {
    await _repository.saveUserFoodPreferences(preferences);
  }
}

