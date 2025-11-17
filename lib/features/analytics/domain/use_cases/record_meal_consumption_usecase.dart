import 'package:smartdolap/features/analytics/domain/entities/meal_consumption.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_meal_consumption_repository.dart';
import 'package:uuid/uuid.dart';

/// Use case for recording meal consumption
class RecordMealConsumptionUseCase {
  /// Creates a use case
  RecordMealConsumptionUseCase(this._repository);

  final IMealConsumptionRepository _repository;
  static const Uuid _uuid = Uuid();

  /// Record meal consumption
  Future<void> call({
    required String householdId,
    required String userId,
    required String recipeId,
    required String recipeTitle,
    required List<String> ingredients,
    required String meal,
  }) async {
    final MealConsumption consumption = MealConsumption(
      id: _uuid.v4(),
      householdId: householdId,
      userId: userId,
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      ingredients: ingredients,
      meal: meal,
      consumedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _repository.recordConsumption(consumption);
  }
}

