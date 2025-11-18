import 'package:smartdolap/features/food_preferences/domain/entities/food_preference.dart';
import 'package:smartdolap/features/food_preferences/domain/repositories/i_food_preference_repository.dart';

/// Use case for getting all food preferences
class GetAllFoodPreferencesUseCase {
  /// Get all food preferences use case constructor
  GetAllFoodPreferencesUseCase(this._repository);

  final IFoodPreferenceRepository _repository;

  /// Execute getting all food preferences
  Future<List<FoodPreference>> call() async {
    return _repository.getAllFoodPreferences();
  }
}

