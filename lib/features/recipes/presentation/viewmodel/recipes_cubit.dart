import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';

class RecipesCubit extends Cubit<RecipesState> {
  RecipesCubit({
    required this.suggest,
    required this.openAI,
    required this.promptPreferences,
    required this.imageLookup,
    Box<dynamic>? cache,
  }) : super(const RecipesInitial());

  final SuggestRecipesFromPantry suggest;
  final IOpenAIService openAI;
  final PromptPreferenceService promptPreferences;
  final ImageLookupService imageLookup;
  Box<dynamic>? _cache = Hive.isBoxOpen('recipes_cache')
      ? Hive.box('recipes_cache')
      : null;
  void setCache(Box<dynamic> box) => _cache = box;
  final Set<String> _seenTitles = <String>{};
  bool isFetchingMore = false;
  Map<String, dynamic> _activeFilters = <String, dynamic>{}; // Current filters

  Future<String?> _fixImageUrl(String? imageUrl, String title) async {
    // OpenAI'den gelen imageUrl'ler genelde çalışmıyor, ImageLookupService kullan
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.contains('example.com') ||
        imageUrl.startsWith('http://example.com') ||
        imageUrl.startsWith('https://example.com')) {
      return await imageLookup.search('$title ${tr('recipe_search_suffix')}');
    }
    return imageUrl;
  }

  Future<void> load(String userId) async {
    emit(const RecipesLoading());
    try {
      final List<Recipe> recipes = await suggest(userId: userId);
      if (isClosed) {
        return;
      }
      emit(RecipesLoaded(recipes, allRecipes: recipes));
      _seenTitles.addAll(recipes.map((Recipe e) => e.title));
      // cache
      _cache ??= Hive.box('recipes_cache');
      await _cache?.put(
        userId,
        recipes
            .map(
              (Recipe e) => <String, Object?>{
                'id': e.id,
                'title': e.title,
                'ingredients': e.ingredients,
                'steps': e.steps,
                'calories': e.calories,
                'durationMinutes': e.durationMinutes,
                'difficulty': e.difficulty,
                'imageUrl': e.imageUrl,
              },
            )
            .toList(),
      );
      await promptPreferences.incrementGenerated(recipes.length);
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(RecipesFailure(e.toString()));
    }
  }

  Future<void> loadWithSelection(
    String userId,
    List<String> names,
    String meal,
  ) async {
    emit(const RecipesLoading());
    try {
      final PromptPreferences prefs = promptPreferences.getPreferences();
      final List<Ingredient> ings = names
          .map((String e) => Ingredient(name: e))
          .toList();
      final List<RecipeSuggestion> suggestions = await openAI.suggestRecipes(
        ings,
        count: 6,
        servings: prefs.servings,
        query: prefs.composePrompt(
          tr('meal_type', namedArgs: <String, String>{'meal': meal}),
        ),
        excludeTitles: _seenTitles.toList(),
      );
      final List<Recipe> recipes = await Future.wait(
        suggestions.map(
          (RecipeSuggestion e) async => Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: e.steps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: await _fixImageUrl(e.imageUrl, e.title),
            category: e.category ?? meal,
          ),
        ),
      );
      _seenTitles.addAll(recipes.map((Recipe e) => e.title));
      await promptPreferences.incrementGenerated(recipes.length);
      if (!isClosed) {
        emit(RecipesLoaded(recipes, allRecipes: recipes));
      }
    } catch (e) {
      if (!isClosed) {
        emit(RecipesFailure(e.toString()));
      }
    }
  }

  Future<void> loadFromText(String csv) async {
    emit(const RecipesLoading());
    try {
      final PromptPreferences prefs = promptPreferences.getPreferences();
      final List<Ingredient> ings = csv
          .split(',')
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .map((String s) => Ingredient(name: s))
          .toList();
      final List<RecipeSuggestion> suggestions = await openAI.suggestRecipes(
        ings,
        servings: prefs.servings,
        query: prefs.composePrompt(tr('free_input_list')),
      );
      if (isClosed) {
        return;
      }
      final List<Recipe> recipes = await Future.wait(
        suggestions.map(
          (RecipeSuggestion e) async => Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: e.steps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: await _fixImageUrl(e.imageUrl, e.title),
          ),
        ),
      );
      await promptPreferences.incrementGenerated(recipes.length);
      emit(RecipesLoaded(recipes, allRecipes: recipes));
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(RecipesFailure(e.toString()));
    }
  }

  Future<void> loadFromCache(String userId) async {
    final Box<dynamic> box = _cache ?? Hive.box('recipes_cache');
    final List<dynamic>? raw = box.get(userId) as List<dynamic>?;
    if (raw == null) {
      return;
    }
    final List<Recipe> recipes = raw
        .map(
          (e) => Recipe(
            id: (e['id'] as String?) ?? '',
            title: e['title'] as String? ?? '',
            ingredients:
                (e['ingredients'] as List?)?.cast<String>() ?? <String>[],
            steps: (e['steps'] as List?)?.cast<String>() ?? <String>[],
            calories: (e['calories'] as num?)?.toInt(),
            durationMinutes: (e['durationMinutes'] as num?)?.toInt(),
            difficulty: e['difficulty'] as String?,
            imageUrl: e['imageUrl'] as String?,
          ),
        )
        .toList();
    if (recipes.isNotEmpty && !isClosed) {
      emit(RecipesLoaded(recipes, allRecipes: recipes));
    }
  }

  // Apply client-side filter from UI without exposing emit
  void applyFilter({
    List<String>? ingredients,
    String? meal,
    int? maxCalories,
    int? minFiber,
  }) {
    final RecipesState s = state;
    if (s is! RecipesLoaded) {
      return;
    }
    final List<Recipe> source = s.allRecipes ?? s.recipes;

    // Update active filters
    _activeFilters = <String, dynamic>{
      if (ingredients != null && ingredients.isNotEmpty)
        'ingredients': ingredients,
      if (meal != null && meal.isNotEmpty) 'meal': meal,
      if (maxCalories != null) 'maxCalories': maxCalories,
      if (minFiber != null) 'minFiber': minFiber,
    };

    // Apply filters
    final List<Recipe> filtered = source.where((Recipe r) {
      final bool ingOk =
          ingredients == null ||
          ingredients.isEmpty ||
          ingredients.every(
            (String name) => r.ingredients
                .map((String e) => e.toLowerCase())
                .contains(name.toLowerCase()),
          );
      final bool mealOk =
          meal == null ||
          meal.isEmpty ||
          (r.category ?? '').toLowerCase() == meal.toLowerCase();
      final bool calOk =
          maxCalories == null || (r.calories ?? 0) <= maxCalories;
      final bool fiberOk = minFiber == null || (r.fiber ?? 0) >= minFiber;
      return ingOk && mealOk && calOk && fiberOk;
    }).toList();

    emit(
      RecipesLoaded(
        filtered,
        allRecipes: source,
        activeFilters: _activeFilters,
      ),
    );
  }

  // Reset filters and show all recipes
  void resetFilters() {
    final RecipesState s = state;
    if (s is! RecipesLoaded) {
      return;
    }
    _activeFilters = <String, dynamic>{};
    emit(
      RecipesLoaded(
        s.allRecipes ?? s.recipes,
        allRecipes: s.allRecipes ?? s.recipes,
        activeFilters: <String, dynamic>{},
      ),
    );
  }

  // Discovery with infinite scroll
  Future<void> discoverInit(String userId, String query) async {
    _seenTitles.clear();
    emit(const RecipesLoading());
    await _discoverFetch(userId, query);
  }

  Future<void> discoverMore(String userId, String query) =>
      _discoverFetch(userId, query);

  Future<void> _discoverFetch(String userId, String query) async {
    final PromptPreferences prefs = promptPreferences.getPreferences();
    try {
      final List<Recipe> current = state is RecipesLoaded
          ? (state as RecipesLoaded).recipes
          : <Recipe>[];
      final List<Recipe> newOnes = await Future.wait(
        (await openAI.suggestRecipes(
          <Ingredient>[],
          query: prefs.composePrompt(query),
          excludeTitles: _seenTitles.toList(),
          count: 6,
          servings: prefs.servings,
        )).map(
          (RecipeSuggestion e) async => Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: e.steps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: await _fixImageUrl(e.imageUrl, e.title),
            category: e.category,
          ),
        ),
      );
      _seenTitles.addAll(newOnes.map((Recipe e) => e.title));
      await promptPreferences.incrementGenerated(newOnes.length);
      final List<Recipe> updated = <Recipe>[...current, ...newOnes];
      emit(
        RecipesLoaded(
          updated,
          allRecipes: updated,
          activeFilters: _activeFilters,
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(RecipesFailure(e.toString()));
      }
    }
  }

  Future<void> loadMoreFromPantry(String userId) async {
    if (isFetchingMore) {
      return;
    }
    final RecipesState s = state;
    final List<Recipe> current = s is RecipesLoaded ? s.recipes : <Recipe>[];
    final PromptPreferences prefs = promptPreferences.getPreferences();
    try {
      isFetchingMore = true;
      emit(RecipesLoaded(current, isLoadingMore: true));
      debugPrint('[RecipesCubit] Loading more pantry suggestions...');
      final List<RecipeSuggestion> more = await openAI.suggestRecipes(
        <Ingredient>[],
        count: 6,
        servings: prefs.servings,
        query: prefs.composePrompt(tr('free_discovery')),
        excludeTitles: _seenTitles.toList(),
      );
      final List<Recipe> mapped = await Future.wait(
        more.map(
          (RecipeSuggestion e) async => Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: e.steps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: await _fixImageUrl(e.imageUrl, e.title),
            category: e.category,
          ),
        ),
      );
      _seenTitles.addAll(mapped.map((Recipe e) => e.title));
      await promptPreferences.incrementGenerated(mapped.length);
      final List<Recipe> updated = <Recipe>[...current, ...mapped];
      emit(
        RecipesLoaded(
          updated,
          allRecipes: updated,
          activeFilters: _activeFilters,
        ),
      );
    } catch (e) {
      // ignore fail silently for load more
      if (!isClosed) {
        emit(RecipesLoaded(current, isLoadingMore: false));
      }
    } finally {
      isFetchingMore = false;
      if (state is RecipesLoaded && !(state as RecipesLoaded).isLoadingMore) {
        debugPrint('[RecipesCubit] Load more finished.');
      }
    }
  }
}
