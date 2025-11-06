// ignore_for_file: public_member_api_docs, avoid_catches_without_on_clauses

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

class RecipesCubit extends Cubit<RecipesState> {
  RecipesCubit({
    required this.suggest,
    required this.openAI,
    Box<dynamic>? cache,
  }) : super(const RecipesInitial());

  final SuggestRecipesFromPantry suggest;
  final IOpenAIService openAI;
  Box<dynamic>? _cache = Hive.isBoxOpen('recipes_cache')
      ? Hive.box('recipes_cache')
      : null;
  void setCache(Box<dynamic> box) => _cache = box;
  final Set<String> _seenTitles = <String>{};
  bool isFetchingMore = false;

  Future<void> load(String userId) async {
    emit(const RecipesLoading());
    try {
      final recipes = await suggest(userId: userId);
      if (isClosed) return;
      emit(RecipesLoaded(recipes));
      _seenTitles.addAll(recipes.map((e) => e.title));
      // cache
      _cache ??= Hive.box('recipes_cache');
      _cache?.put(
        userId,
        recipes
            .map(
              (e) => {
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
    } catch (e) {
      if (isClosed) return;
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
      final List<Ingredient> ings = names
          .map((e) => Ingredient(name: e))
          .toList();
      final suggestions = await openAI.suggestRecipes(
        ings,
        count: 6,
        servings: 2,
        query: 'öğün: $meal',
        excludeTitles: _seenTitles.toList(),
      );
      final recipes = suggestions
          .map(
            (e) => Recipe(
              id: '',
              title: e.title,
              ingredients: e.ingredients,
              steps: e.steps,
              calories: e.calories,
              durationMinutes: e.durationMinutes,
              difficulty: e.difficulty,
              imageUrl: e.imageUrl,
              category: e.category ?? meal,
            ),
          )
          .toList();
      _seenTitles.addAll(recipes.map((e) => e.title));
      if (!isClosed) emit(RecipesLoaded(recipes));
    } catch (e) {
      if (!isClosed) emit(RecipesFailure(e.toString()));
    }
  }

  Future<void> loadFromText(String csv) async {
    emit(const RecipesLoading());
    try {
      final List<Ingredient> ings = csv
          .split(',')
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .map((String s) => Ingredient(name: s))
          .toList();
      final suggestions = await openAI.suggestRecipes(ings);
      if (isClosed) return;
      emit(
        RecipesLoaded(
          suggestions
              .map(
                (e) => Recipe(
                  id: '',
                  title: e.title,
                  ingredients: e.ingredients,
                  steps: e.steps,
                  calories: e.calories,
                  durationMinutes: e.durationMinutes,
                  difficulty: e.difficulty,
                  imageUrl: e.imageUrl,
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(RecipesFailure(e.toString()));
    }
  }

  Future<void> loadFromCache(String userId) async {
    final Box<dynamic> box = _cache ?? Hive.box('recipes_cache');
    final List<dynamic>? raw = box.get(userId) as List<dynamic>?;
    if (raw == null) return;
    final recipes = raw
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
    if (recipes.isNotEmpty && !isClosed) emit(RecipesLoaded(recipes));
  }

  // Apply client-side filter from UI without exposing emit
  void applyFilter(List<Recipe> recipes) {
    emit(RecipesLoaded(recipes));
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
    try {
      final List<Recipe> current = state is RecipesLoaded
          ? (state as RecipesLoaded).recipes
          : <Recipe>[];
      final List<Recipe> newOnes =
          (await openAI.suggestRecipes(
                <Ingredient>[],
                query: query,
                excludeTitles: _seenTitles.toList(),
                count: 6,
                servings: 2,
              ))
              .map(
                (e) => Recipe(
                  id: '',
                  title: e.title,
                  ingredients: e.ingredients,
                  steps: e.steps,
                  calories: e.calories,
                  durationMinutes: e.durationMinutes,
                  difficulty: e.difficulty,
                  imageUrl: e.imageUrl,
                  category: e.category,
                ),
              )
              .toList();
      _seenTitles.addAll(newOnes.map((e) => e.title));
      emit(RecipesLoaded(<Recipe>[...current, ...newOnes]));
    } catch (e) {
      if (!isClosed) emit(RecipesFailure(e.toString()));
    }
  }

  Future<void> loadMoreFromPantry(String userId) async {
    if (isFetchingMore) return;
    final RecipesState s = state;
    final List<Recipe> current = s is RecipesLoaded ? s.recipes : <Recipe>[];
    try {
      isFetchingMore = true;
      final List<RecipeSuggestion> more = await openAI.suggestRecipes(
        <Ingredient>[],
        count: 6,
        servings: 2,
        excludeTitles: _seenTitles.toList(),
      );
      final List<Recipe> mapped = more
          .map(
            (e) => Recipe(
              id: '',
              title: e.title,
              ingredients: e.ingredients,
              steps: e.steps,
              calories: e.calories,
              durationMinutes: e.durationMinutes,
              difficulty: e.difficulty,
              imageUrl: e.imageUrl,
              category: e.category,
            ),
          )
          .toList();
      _seenTitles.addAll(mapped.map((e) => e.title));
      emit(RecipesLoaded(<Recipe>[...current, ...mapped]));
    } catch (e) {
      // ignore fail silently for load more
    } finally {
      isFetchingMore = false;
    }
  }
}
