import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/analytics/domain/entities/ingredient_usage.dart';
import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_meal_consumption_repository.dart';
import 'package:smartdolap/features/analytics/domain/services/i_analytics_service.dart';
import 'package:smartdolap/features/analytics/domain/use_cases/record_meal_consumption_usecase.dart';

/// Service implementation for analytics calculations
class AnalyticsServiceImpl implements IAnalyticsService {
  AnalyticsServiceImpl(
    this._analyticsRepository,
    this._mealConsumptionRepository,
  );

  final IAnalyticsRepository _analyticsRepository;
  final IMealConsumptionRepository _mealConsumptionRepository;

  @override
  Future<UserAnalytics> analyzeUser({
    required String userId,
    required String householdId,
  }) async {
    try {
      return _analyticsRepository.calculateAnalytics(
        userId: userId,
        householdId: householdId,
      );
    } catch (e) {
      Logger.error('[AnalyticsService] Error analyzing user', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, IngredientUsage>> getIngredientUsage({
    required String userId,
    required String householdId,
  }) async {
    try {
      final UserAnalytics analytics = await analyzeUser(
        userId: userId,
        householdId: householdId,
      );
      return analytics.ingredientUsage;
    } catch (e) {
      Logger.error('[AnalyticsService] Error getting ingredient usage', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, double>> getDietaryPattern({
    required String userId,
    required String householdId,
  }) async {
    try {
      final UserAnalytics analytics = await analyzeUser(
        userId: userId,
        householdId: householdId,
      );
      return analytics.dietaryPattern;
    } catch (e) {
      Logger.error('[AnalyticsService] Error getting dietary pattern', e);
      rethrow;
    }
  }

  @override
  Future<void> recordRecipeConsumption({
    required String userId,
    required String householdId,
    required String recipeId,
    required String recipeTitle,
    required List<String> ingredients,
    required String meal,
  }) async {
    try {
      final RecordMealConsumptionUseCase recordUseCase =
          RecordMealConsumptionUseCase(_mealConsumptionRepository);

      await recordUseCase.call(
        householdId: householdId,
        userId: userId,
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        ingredients: ingredients,
        meal: meal,
      );

      // Invalidate analytics cache to force recalculation
      // Analytics will be recalculated on next request
      Logger.info(
        '[AnalyticsService] Recorded recipe consumption: $recipeTitle',
      );
    } catch (e) {
      Logger.error('[AnalyticsService] Error recording consumption', e);
      rethrow;
    }
  }
}
