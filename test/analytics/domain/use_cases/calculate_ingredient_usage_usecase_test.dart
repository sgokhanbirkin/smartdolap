import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/analytics/domain/entities/ingredient_usage.dart';
import 'package:smartdolap/features/analytics/domain/services/i_analytics_service.dart';
import 'package:smartdolap/features/analytics/domain/use_cases/calculate_ingredient_usage_usecase.dart';

class _MockAnalyticsService extends Mock implements IAnalyticsService {}

void main() {
  const String userId = 'user-1';
  const String householdId = 'house-1';

  late _MockAnalyticsService service;
  late CalculateIngredientUsageUseCase useCase;

  setUp(() {
    service = _MockAnalyticsService();
    useCase = CalculateIngredientUsageUseCase(service);
  });

  test('delegates calculation to analytics service', () async {
    final Map<String, IngredientUsage> usage = <String, IngredientUsage>{
      'egg': IngredientUsage(
        ingredientName: 'egg',
        totalUsed: 3,
        averageDailyUsage: 1,
        usageDates: <DateTime>[DateTime(2024)],
        usageByMeal: <String, int>{'breakfast': 3},
        lastUsed: DateTime(2024, 1, 2),
      ),
    };

    when(
      () => service.getIngredientUsage(
        userId: userId,
        householdId: householdId,
      ),
    ).thenAnswer((_) async => usage);

    final Map<String, IngredientUsage> result = await useCase(
      userId: userId,
      householdId: householdId,
    );

    expect(result, usage);
    verify(
      () => service.getIngredientUsage(
        userId: userId,
        householdId: householdId,
      ),
    ).called(1);
  });
}

