import 'package:smartdolap/features/analytics/domain/entities/ingredient_usage.dart';
import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';

/// Service interface for analytics calculations
/// Follows Dependency Inversion Principle (DIP)
abstract class IAnalyticsService {
  /// Analyze user and return analytics
  Future<UserAnalytics> analyzeUser({
    required String userId,
    required String householdId,
  });

  /// Get ingredient usage statistics
  Future<Map<String, IngredientUsage>> getIngredientUsage({
    required String userId,
    required String householdId,
  });

  /// Get dietary pattern analysis
  Future<Map<String, double>> getDietaryPattern({
    required String userId,
    required String householdId,
  });

  /// Record recipe consumption
  Future<void> recordRecipeConsumption({
    required String userId,
    required String householdId,
    required String recipeId,
    required String recipeTitle,
    required List<String> ingredients,
    required String meal,
  });
}

