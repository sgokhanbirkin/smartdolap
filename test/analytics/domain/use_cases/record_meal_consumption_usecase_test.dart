import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/analytics/domain/entities/meal_consumption.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_meal_consumption_repository.dart';
import 'package:smartdolap/features/analytics/domain/use_cases/record_meal_consumption_usecase.dart';

class _MockMealConsumptionRepository extends Mock
    implements IMealConsumptionRepository {}

void main() {
  const String householdId = 'house-1';
  const String userId = 'user-1';
  const String recipeId = 'recipe-1';
  const String recipeTitle = 'Mercimek Çorbası';
  const List<String> ingredients = <String>['Mercimek', 'Su'];
  const String meal = 'lunch';

  late _MockMealConsumptionRepository repository;
  late RecordMealConsumptionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      MealConsumption(
        id: 'fallback',
        householdId: householdId,
        userId: userId,
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        ingredients: ingredients,
        meal: meal,
        consumedAt: DateTime(2024),
        createdAt: DateTime(2024),
      ),
    );
  });

  setUp(() {
    repository = _MockMealConsumptionRepository();
    useCase = RecordMealConsumptionUseCase(repository);
  });

  test('records meal consumption with generated id and current timestamps',
      () async {
    when(() => repository.recordConsumption(any())).thenAnswer((_) async {});

    final DateTime beforeCall = DateTime.now();

    await useCase(
      householdId: householdId,
      userId: userId,
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      ingredients: ingredients,
      meal: meal,
    );

    final MealConsumption captured =
        verify(() => repository.recordConsumption(captureAny())).captured.single
            as MealConsumption;

    expect(captured.householdId, householdId);
    expect(captured.userId, userId);
    expect(captured.recipeId, recipeId);
    expect(captured.recipeTitle, recipeTitle);
    expect(captured.ingredients, ingredients);
    expect(captured.meal, meal);
    expect(captured.id, isNotEmpty);
    expect(captured.consumedAt.isAfter(beforeCall), isTrue);
    expect(captured.createdAt.isAfter(beforeCall), isTrue);
  });
}

