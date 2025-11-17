import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';

/// Mock IRecipesRepository
class MockRecipesRepository extends Mock implements IRecipesRepository {}

void main() {
  group('SuggestRecipesFromPantry', () {
    late MockRecipesRepository mockRepository;
    late SuggestRecipesFromPantry suggestRecipesFromPantry;

    setUp(() {
      mockRepository = MockRecipesRepository();
      suggestRecipesFromPantry = SuggestRecipesFromPantry(mockRepository);
    });

    test('should return list of recipes from repository', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      final List<Recipe> testRecipes = <Recipe>[
        const Recipe(
          id: 'recipe-1',
          title: 'Yumurta Salatası',
          ingredients: <String>['Yumurta', 'Mayonez'],
          steps: <String>['Yumurtaları haşla', 'Doğra ve karıştır'],
          calories: 200,
          durationMinutes: 15,
          difficulty: 'kolay',
          category: 'kahvaltı',
        ),
        const Recipe(
          id: 'recipe-2',
          title: 'Mantarlı Omlet',
          ingredients: <String>['Yumurta', 'Mantar'],
          steps: <String>['Mantarları kızart', 'Yumurta ekle'],
          calories: 250,
          durationMinutes: 20,
          difficulty: 'orta',
          category: 'kahvaltı',
        ),
      ];

      when(
        () => mockRepository.suggestFromPantry(householdId: testUserId),
      ).thenAnswer((_) async => testRecipes);

      // Act
      final List<Recipe> result =
          await suggestRecipesFromPantry(householdId: testUserId);

      // Assert
      expect(result.length, equals(2));
      expect(result.first.title, equals('Yumurta Salatası'));
      expect(result.last.title, equals('Mantarlı Omlet'));
      expect(result.first.category, equals('kahvaltı'));
      verify(() => mockRepository.suggestFromPantry(householdId: testUserId))
          .called(1);
    });

    test('should return empty list when repository returns empty', () async {
      // Arrange
      const String testUserId = 'test-user-123';

      when(
        () => mockRepository.suggestFromPantry(householdId: testUserId),
      ).thenAnswer((_) async => <Recipe>[]);

      // Act
      final List<Recipe> result =
          await suggestRecipesFromPantry(householdId: testUserId);

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.suggestFromPantry(householdId: testUserId))
          .called(1);
    });

    test('should return recipes with missing ingredient count', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      final List<Recipe> testRecipes = <Recipe>[
        const Recipe(
          id: 'recipe-1',
          title: 'Test Recipe',
          ingredients: <String>['Yumurta', 'Süt', 'Un'],
          steps: <String>['Karıştır'],
          missingCount: 1,
        ),
      ];

      when(
        () => mockRepository.suggestFromPantry(householdId: testUserId),
      ).thenAnswer((_) async => testRecipes);

      // Act
      final List<Recipe> result =
          await suggestRecipesFromPantry(householdId: testUserId);

      // Assert
      expect(result.first.missingCount, equals(1));
      verify(() => mockRepository.suggestFromPantry(householdId: testUserId))
          .called(1);
    });

    test('should propagate errors from repository', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      final Exception testError = Exception('Repository error');

      when(
        () => mockRepository.suggestFromPantry(householdId: testUserId),
      ).thenThrow(testError);

      // Act & Assert
      expect(
        () => suggestRecipesFromPantry(householdId: testUserId),
        throwsA(testError),
      );
      verify(() => mockRepository.suggestFromPantry(householdId: testUserId))
          .called(1);
    });
  });
}

