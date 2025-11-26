import 'package:smartdolap/features/food_preferences/domain/entities/user_food_preferences.dart';
import 'package:smartdolap/features/food_preferences/domain/repositories/i_food_preference_repository.dart';

/// Use case for getting user food preferences
class GetUserFoodPreferencesUseCase {
  /// Get user food preferences use case constructor
  GetUserFoodPreferencesUseCase(this._repository);

  final IFoodPreferenceRepository _repository;

  /// Execute getting user food preferences
  Future<UserFoodPreferences?> call(String userId) async => _repository.getUserFoodPreferences(userId);
}

