import 'package:smartdolap/features/food_preferences/domain/entities/food_preference.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/user_food_preferences.dart';

/// Food preference repository contract
abstract class IFoodPreferenceRepository {
  /// Get all available food preferences
  Future<List<FoodPreference>> getAllFoodPreferences();

  /// Save user's food preferences
  Future<void> saveUserFoodPreferences(UserFoodPreferences preferences);

  /// Get user's food preferences
  Future<UserFoodPreferences?> getUserFoodPreferences(String userId);

  /// Stream user's food preferences
  Stream<UserFoodPreferences?> watchUserFoodPreferences(String userId);

  /// Get household food preferences (aggregated from all members)
  Future<Map<String, dynamic>> getHouseholdFoodPreferences(String householdId);
}

