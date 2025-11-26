import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/analytics/domain/entities/ingredient_usage.dart';
import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:smartdolap/features/analytics/domain/use_cases/get_user_analytics_usecase.dart';

class _MockAnalyticsRepository extends Mock implements IAnalyticsRepository {}

void main() {
  const String userId = 'user-1';
  const String householdId = 'house-1';

  late _MockAnalyticsRepository repository;
  late GetUserAnalyticsUseCase useCase;

  UserAnalytics buildAnalytics(DateTime lastUpdated) => UserAnalytics(
        userId: userId,
        householdId: householdId,
        mealTimeDistribution: <String, int>{'08:00': 2},
        mealTypeDistribution: <String, int>{'breakfast': 2},
        ingredientUsage: <String, IngredientUsage>{
          'egg': IngredientUsage(
            ingredientName: 'egg',
            totalUsed: 5,
            averageDailyUsage: 1.0,
            usageDates: <DateTime>[DateTime(2024)],
            usageByMeal: <String, int>{'breakfast': 5},
            lastUsed: DateTime(2024, 1, 2),
          ),
        },
        categoryUsage: <String, int>{'protein': 5},
        dietaryPattern: <String, double>{'protein_heavy': 0.7},
        lastUpdated: lastUpdated,
      );

  setUp(() {
    repository = _MockAnalyticsRepository();
    useCase = GetUserAnalyticsUseCase(repository);
  });

  test(
    'returns cached analytics when cache is fresher than 1 hour',
    () async {
      final UserAnalytics cached =
          buildAnalytics(DateTime.now().subtract(const Duration(minutes: 30)));

      when(
        () => repository.getCachedAnalytics(
          userId: userId,
          householdId: householdId,
        ),
      ).thenAnswer((_) async => cached);

      final UserAnalytics result = await useCase(
        userId: userId,
        householdId: householdId,
      );

      expect(result, same(cached));
      verify(
        () => repository.getCachedAnalytics(
          userId: userId,
          householdId: householdId,
        ),
      ).called(1);
      verifyNever(
        () => repository.calculateAnalytics(
          userId: any(named: 'userId'),
          householdId: any(named: 'householdId'),
        ),
      );
    },
  );

  test(
    'fetches fresh analytics when cache is missing',
    () async {
      final UserAnalytics fresh = buildAnalytics(DateTime.now());

      when(
        () => repository.getCachedAnalytics(
          userId: userId,
          householdId: householdId,
        ),
      ).thenAnswer((_) async => null);

      when(
        () => repository.calculateAnalytics(
          userId: userId,
          householdId: householdId,
        ),
      ).thenAnswer((_) async => fresh);

      final UserAnalytics result = await useCase(
        userId: userId,
        householdId: householdId,
      );

      expect(result, same(fresh));
      verify(
        () => repository.calculateAnalytics(
          userId: userId,
          householdId: householdId,
        ),
      ).called(1);
    },
  );

  test(
    'fetches fresh analytics when cache is older than 1 hour',
    () async {
      final UserAnalytics stale =
          buildAnalytics(DateTime.now().subtract(const Duration(hours: 2)));
      final UserAnalytics fresh = buildAnalytics(DateTime.now());

      when(
        () => repository.getCachedAnalytics(
          userId: userId,
          householdId: householdId,
        ),
      ).thenAnswer((_) async => stale);

      when(
        () => repository.calculateAnalytics(
          userId: userId,
          householdId: householdId,
        ),
      ).thenAnswer((_) async => fresh);

      final UserAnalytics result = await useCase(
        userId: userId,
        householdId: householdId,
      );

      expect(result, same(fresh));
      verify(
        () => repository.calculateAnalytics(
          userId: userId,
          householdId: householdId,
        ),
      ).called(1);
    },
  );
}

