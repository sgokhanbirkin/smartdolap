import 'package:smartdolap/features/analytics/domain/entities/meal_consumption.dart';

/// Repository interface for meal consumption tracking
/// Follows Dependency Inversion Principle (DIP)
abstract class IMealConsumptionRepository {
  /// Record a meal consumption
  Future<void> recordConsumption(MealConsumption consumption);

  /// Watch consumptions as a stream
  Stream<List<MealConsumption>> watchConsumptions({
    required String householdId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get consumptions
  Future<List<MealConsumption>> getConsumptions({
    required String householdId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
