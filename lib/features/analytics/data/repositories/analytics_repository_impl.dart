import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/analytics/domain/entities/ingredient_usage.dart';
import 'package:smartdolap/features/analytics/domain/entities/meal_consumption.dart';
import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_meal_consumption_repository.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';

/// Firestore implementation for analytics repository
class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  AnalyticsRepositoryImpl(
    this._firestore,
    this._mealConsumptionRepository,
    this._pantryRepository,
  );

  final FirebaseFirestore _firestore;
  final IMealConsumptionRepository _mealConsumptionRepository;
  final IPantryRepository _pantryRepository;
  static const String _users = 'users';
  static const String _analytics = 'analytics';

  DocumentReference<Map<String, dynamic>> _doc(String userId) => _firestore
      .collection(_users)
      .doc(userId)
      .collection(_analytics)
      .doc('data');

  @override
  Future<UserAnalytics> calculateAnalytics({
    required String userId,
    required String householdId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Default to last 30 days if not specified
      final DateTime defaultStartDate =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final DateTime defaultEndDate = endDate ?? DateTime.now();

      // Get meal consumptions
      final List<MealConsumption> consumptions =
          await _mealConsumptionRepository.getConsumptions(
            householdId: householdId,
            userId: userId,
            startDate: defaultStartDate,
            endDate: defaultEndDate,
          );

      // Calculate meal time distribution
      final Map<String, int> mealTimeDistribution = <String, int>{};
      for (final MealConsumption consumption in consumptions) {
        final String hour =
            '${consumption.consumedAt.hour.toString().padLeft(2, '0')}:00';
        mealTimeDistribution[hour] = (mealTimeDistribution[hour] ?? 0) + 1;
      }

      // Calculate meal type distribution
      final Map<String, int> mealTypeDistribution = <String, int>{};
      for (final MealConsumption consumption in consumptions) {
        mealTypeDistribution[consumption.meal] =
            (mealTypeDistribution[consumption.meal] ?? 0) + 1;
      }

      // Calculate ingredient usage
      final Map<String, IngredientUsage> ingredientUsage =
          <String, IngredientUsage>{};
      final Map<String, List<DateTime>> ingredientDates =
          <String, List<DateTime>>{};
      final Map<String, Map<String, int>> ingredientMealUsage =
          <String, Map<String, int>>{};

      for (final MealConsumption consumption in consumptions) {
        for (final String ingredient in consumption.ingredients) {
          // Normalize ingredient name (lowercase, trim)
          final String normalizedIngredient = ingredient.toLowerCase().trim();

          // Track usage dates
          ingredientDates.putIfAbsent(normalizedIngredient, () => <DateTime>[]);
          ingredientDates[normalizedIngredient]!.add(consumption.consumedAt);

          // Track usage by meal
          ingredientMealUsage.putIfAbsent(
            normalizedIngredient,
            () => <String, int>{},
          );
          ingredientMealUsage[normalizedIngredient]![consumption.meal] =
              (ingredientMealUsage[normalizedIngredient]![consumption.meal] ??
                  0) +
              1;
        }
      }

      // Calculate average daily usage and create IngredientUsage objects
      for (final MapEntry<String, List<DateTime>> entry
          in ingredientDates.entries) {
        final List<DateTime> dates = entry.value;
        dates.sort();

        // Calculate days between first and last usage
        final int daysDiff = defaultEndDate.difference(defaultStartDate).inDays;
        final double averageDailyUsage = daysDiff > 0
            ? dates.length / daysDiff
            : dates.length.toDouble();

        ingredientUsage[entry.key] = IngredientUsage(
          ingredientName: entry.key,
          totalUsed: dates.length,
          averageDailyUsage: averageDailyUsage,
          usageDates: dates,
          usageByMeal: ingredientMealUsage[entry.key] ?? <String, int>{},
          lastUsed: dates.isNotEmpty ? dates.last : DateTime.now(),
        );
      }

      // Calculate category usage (from pantry items used in recipes)
      final Map<String, int> categoryUsage = <String, int>{};
      final List<String> allIngredients = ingredientUsage.keys.toList();

      // Get pantry items to match categories
      final List<PantryItem> pantryItems = await _pantryRepository.getItems(
        householdId: householdId,
      );
      final Map<String, String> ingredientToCategory = <String, String>{};

      for (final PantryItem pantryItem in pantryItems) {
        final String normalizedName = pantryItem.name.toLowerCase().trim();
        if (pantryItem.category != null) {
          ingredientToCategory[normalizedName] = pantryItem.category!;
        }
      }

      // Count category usage
      for (final String ingredient in allIngredients) {
        final String? category = ingredientToCategory[ingredient];
        if (category != null) {
          final String normalizedCategory = PantryCategoryHelper.normalize(
            category,
          );
          categoryUsage[normalizedCategory] =
              (categoryUsage[normalizedCategory] ?? 0) +
              (ingredientUsage[ingredient]?.totalUsed ?? 0);
        }
      }

      // Calculate dietary pattern
      final Map<String, double> dietaryPattern = <String, double>{};
      final int totalMeals = consumptions.length;

      if (totalMeals > 0) {
        // Vegetable-heavy: if vegetables category usage > 40% of total
        final int vegetableUsage = categoryUsage['vegetables'] ?? 0;
        dietaryPattern['vegetable_heavy'] = vegetableUsage / totalMeals;

        // Protein-heavy: if meat/dairy category usage > 40% of total
        final int proteinUsage =
            (categoryUsage['meat'] ?? 0) + (categoryUsage['dairy'] ?? 0);
        dietaryPattern['protein_heavy'] = proteinUsage / totalMeals;

        // Balanced: if neither is dominant
        dietaryPattern['balanced'] =
            1.0 -
            (dietaryPattern['vegetable_heavy']! +
                dietaryPattern['protein_heavy']!);
      } else {
        dietaryPattern['balanced'] = 1.0;
      }

      final UserAnalytics analytics = UserAnalytics(
        userId: userId,
        householdId: householdId,
        mealTimeDistribution: mealTimeDistribution,
        mealTypeDistribution: mealTypeDistribution,
        ingredientUsage: ingredientUsage,
        categoryUsage: categoryUsage,
        dietaryPattern: dietaryPattern,
        lastUpdated: DateTime.now(),
      );

      // Cache the analytics
      await updateAnalytics(analytics);

      return analytics;
    } catch (e) {
      Logger.error('[AnalyticsRepository] Error calculating analytics', e);
      rethrow;
    }
  }

  @override
  Future<UserAnalytics?> getCachedAnalytics({
    required String userId,
    required String householdId,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _doc(
        userId,
      ).get();

      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      final Map<String, dynamic> data = snapshot.data()!;
      return UserAnalytics.fromJson(data);
    } on Object catch (error, stackTrace) {
      Logger.error(
        '[AnalyticsRepository] Error getting cached analytics',
        error,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> updateAnalytics(UserAnalytics analytics) async {
    try {
      await _doc(analytics.userId).set(analytics.toJson());
      Logger.info('[AnalyticsRepository] Updated analytics cache');
    } on Object catch (error, stackTrace) {
      Logger.error(
        '[AnalyticsRepository] Error updating analytics',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Stream<UserAnalytics> watchAnalytics({
    required String userId,
    required String householdId,
  }) => _doc(userId).snapshots().map((
      DocumentSnapshot<Map<String, dynamic>> snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) {
        // Return empty analytics if not found
        return UserAnalytics(
          userId: userId,
          householdId: householdId,
          mealTimeDistribution: <String, int>{},
          mealTypeDistribution: <String, int>{},
          ingredientUsage: <String, IngredientUsage>{},
          categoryUsage: <String, int>{},
          dietaryPattern: <String, double>{},
          lastUpdated: DateTime.now(),
        );
      }

      return UserAnalytics.fromJson(snapshot.data()!);
    });
}
