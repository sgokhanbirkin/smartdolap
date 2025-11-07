import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';

/// Mock classes
class MockSuggestRecipesFromPantry extends Mock
    implements SuggestRecipesFromPantry {}

class MockIOpenAIService extends Mock implements IOpenAIService {}

class MockPromptPreferenceService extends Mock
    implements PromptPreferenceService {}

class MockImageLookupService extends Mock implements ImageLookupService {}

void main() {
  // Hive initialization for tests
  setUpAll(() async {
    Hive.init('test/hive_test');
  });

  setUp(() async {
    // Clean up any existing boxes
    if (Hive.isBoxOpen('recipes_cache')) {
      await Hive.box<dynamic>('recipes_cache').close();
    }
  });

  tearDown(() async {
    // Clean up boxes after each test
    if (Hive.isBoxOpen('recipes_cache')) {
      await Hive.box<dynamic>('recipes_cache').deleteFromDisk();
    }
  });

  group('RecipesCubit', () {
    late MockSuggestRecipesFromPantry mockSuggest;
    late MockIOpenAIService mockOpenAI;
    late MockPromptPreferenceService mockPromptPreferences;
    late MockImageLookupService mockImageLookup;
    late Box<dynamic> cacheBox;

    setUp(() async {
      mockSuggest = MockSuggestRecipesFromPantry();
      mockOpenAI = MockIOpenAIService();
      mockPromptPreferences = MockPromptPreferenceService();
      mockImageLookup = MockImageLookupService();
      // Open Hive box for each test
      if (Hive.isBoxOpen('recipes_cache')) {
        await Hive.box<dynamic>('recipes_cache').close();
      }
      cacheBox = await Hive.openBox<dynamic>('recipes_cache');
    });

    test('initial state should be RecipesInitial', () {
      // Act
      final RecipesCubit cubit = RecipesCubit(
        suggest: mockSuggest,
        openAI: mockOpenAI,
        promptPreferences: mockPromptPreferences,
        imageLookup: mockImageLookup,
      );

      // Assert
      expect(cubit.state, const RecipesInitial());
    });

    blocTest<RecipesCubit, RecipesState>(
      'should emit [loading, loaded] when load is successful',
      setUp: () {
        const String testUserId = 'test-user-123';
        final List<Recipe> testRecipes = <Recipe>[
          const Recipe(
            id: 'recipe-1',
            title: 'Test Recipe',
            ingredients: <String>['Ingredient 1'],
            steps: <String>['Step 1'],
          ),
        ];

        when(
          () => mockSuggest(userId: testUserId),
        ).thenAnswer((_) async => testRecipes);
        when(
          () => mockPromptPreferences.incrementGenerated(any()),
        ).thenAnswer((_) async => Future<void>.value());
      },
      build: () => RecipesCubit(
        suggest: mockSuggest,
        openAI: mockOpenAI,
        promptPreferences: mockPromptPreferences,
        imageLookup: mockImageLookup,
        cache: cacheBox,
      ),
      act: (RecipesCubit cubit) => cubit.load('test-user-123'),
      expect: () => <Matcher>[
        isA<RecipesLoading>(),
        isA<RecipesLoaded>().having(
          (RecipesLoaded s) => s.recipes.length,
          'recipes.length',
          1,
        ),
      ],
      verify: (_) {
        verify(() => mockSuggest(userId: 'test-user-123')).called(1);
        verify(() => mockPromptPreferences.incrementGenerated(1)).called(1);
      },
    );

    blocTest<RecipesCubit, RecipesState>(
      'should emit [loading, failure] when load fails',
      setUp: () {
        const String testUserId = 'test-user-123';
        final Exception testError = Exception('Load error');

        when(() => mockSuggest(userId: testUserId)).thenThrow(testError);
      },
      build: () => RecipesCubit(
        suggest: mockSuggest,
        openAI: mockOpenAI,
        promptPreferences: mockPromptPreferences,
        imageLookup: mockImageLookup,
      ),
      act: (RecipesCubit cubit) => cubit.load('test-user-123'),
      expect: () => <Matcher>[
        isA<RecipesLoading>(),
        isA<RecipesFailure>().having(
          (RecipesFailure s) => s.message,
          'message',
          'Exception: Load error',
        ),
      ],
    );

    blocTest<RecipesCubit, RecipesState>(
      'should apply filter correctly',
      setUp: () {
        // Test setup - no need to store unused variable
      },
      build: () => RecipesCubit(
        suggest: mockSuggest,
        openAI: mockOpenAI,
        promptPreferences: mockPromptPreferences,
        imageLookup: mockImageLookup,
      ),
      seed: () => const RecipesLoaded(<Recipe>[
        Recipe(
          id: 'recipe-1',
          title: 'Recipe 1',
          ingredients: <String>['Ingredient 1'],
          steps: <String>['Step 1'],
          category: 'kahvaltı',
        ),
        Recipe(
          id: 'recipe-2',
          title: 'Recipe 2',
          ingredients: <String>['Ingredient 2'],
          steps: <String>['Step 2'],
          category: 'akşam',
        ),
      ]),
      act: (RecipesCubit cubit) {
        cubit.applyFilter(meal: 'kahvaltı');
      },
      expect: () => <Matcher>[
        isA<RecipesLoaded>()
            .having((RecipesLoaded s) => s.recipes.length, 'recipes.length', 1)
            .having(
              (RecipesLoaded s) => s.recipes.first.category,
              'recipes.first.category',
              'kahvaltı',
            ),
      ],
    );

    blocTest<RecipesCubit, RecipesState>(
      'should emit loaded with isLoadingMore when loadMoreFromPantry is called',
      setUp: () {
        const PromptPreferences testPrefs = PromptPreferences(servings: 2);
        final List<RecipeSuggestion> testSuggestions = <RecipeSuggestion>[
          const RecipeSuggestion(
            title: 'New Recipe',
            ingredients: <String>['Ingredient'],
            steps: <String>['Step'],
          ),
        ];

        when(
          () => mockPromptPreferences.getPreferences(),
        ).thenReturn(testPrefs);
        when(
          () => mockOpenAI.suggestRecipes(
            any(),
            count: any(named: 'count'),
            servings: any(named: 'servings'),
            query: any(named: 'query'),
            excludeTitles: any(named: 'excludeTitles'),
          ),
        ).thenAnswer((_) async => testSuggestions);
        when(
          () => mockImageLookup.search(any()),
        ).thenAnswer((_) async => 'https://example.com/image.jpg');
        when(
          () => mockPromptPreferences.incrementGenerated(any()),
        ).thenAnswer((_) async => Future<void>.value());
      },
      build: () => RecipesCubit(
        suggest: mockSuggest,
        openAI: mockOpenAI,
        promptPreferences: mockPromptPreferences,
        imageLookup: mockImageLookup,
      ),
      seed: () => const RecipesLoaded(<Recipe>[
        Recipe(
          id: 'recipe-1',
          title: 'Existing Recipe',
          ingredients: <String>['Ingredient'],
          steps: <String>['Step'],
        ),
      ]),
      act: (RecipesCubit cubit) => cubit.loadMoreFromPantry('test-user-123'),
      wait: const Duration(milliseconds: 100),
      expect: () => <Matcher>[
        isA<RecipesLoaded>().having(
          (RecipesLoaded s) => s.isLoadingMore,
          'isLoadingMore',
          true,
        ),
        isA<RecipesLoaded>()
            .having(
              (RecipesLoaded s) => s.isLoadingMore,
              'isLoadingMore',
              false,
            )
            .having(
              (RecipesLoaded s) => s.recipes.length,
              'recipes.length',
              greaterThan(1),
            ),
      ],
    );
  });
}
