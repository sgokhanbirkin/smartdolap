import 'package:smartdolap/features/analytics/domain/entities/ingredient_usage.dart';
import 'package:smartdolap/features/analytics/domain/services/i_analytics_service.dart';

/// Use case for calculating ingredient usage
class CalculateIngredientUsageUseCase {
  /// Creates a use case
  CalculateIngredientUsageUseCase(this._service);

  final IAnalyticsService _service;

  /// Calculate ingredient usage
  Future<Map<String, IngredientUsage>> call({
    required String userId,
    required String householdId,
  }) async {
    return _service.getIngredientUsage(
      userId: userId,
      householdId: householdId,
    );
  }
}

