import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_user_recipe_repository.dart';
import 'package:smartdolap/features/recipes/data/services/meal_name_mapper.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_cache_service.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_image_service.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_mapper.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:uuid/uuid.dart';

class RecipesCubit extends Cubit<RecipesState> {
  RecipesCubit({
    required this.suggest,
    required this.openAI,
    required this.promptPreferences,
    required this.imageLookup,
    required this.cacheService,
    required this.imageService,
    required this.userRecipeRepository,
  }) : super(const RecipesInitial());

  final SuggestRecipesFromPantry suggest;
  final IOpenAIService openAI;
  final PromptPreferenceService promptPreferences;
  final ImageLookupService imageLookup;
  final RecipeCacheService cacheService;
  final RecipeImageService imageService;
  final IUserRecipeRepository userRecipeRepository;

  final Set<String> _seenTitles = <String>{};
  bool isFetchingMore = false;
  Map<String, dynamic> _activeFilters = <String, dynamic>{};
  String _currentCategory = 'suggestions';
  String? _selectedMeal;

  Future<void> load(String userId) async {
    emit(const RecipesLoading());
    try {
      // suggest() zaten görselleri düzeltiyor (RecipesRepository içinde)
      final List<Recipe> recipes = await suggest(userId: userId);

      if (isClosed) {
        return;
      }
      emit(RecipesLoaded(recipes, allRecipes: recipes));
      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      await promptPreferences.incrementGenerated(recipes.length);
    } on Exception catch (e) {
      debugPrint('[RecipesCubit] load hatası: $e');
      if (isClosed) {
        return;
      }
      emit(RecipesFailure(e.toString()));
    }
  }

  Future<void> loadWithSelection(
    String userId,
    List<String> names,
    String meal, {
    String? note,
  }) async {
    emit(const RecipesLoading());
    try {
      final PromptPreferences prefs = promptPreferences.getPreferences();
      final List<Ingredient> ings = names
          .map((String e) => Ingredient(name: e))
          .toList();

      // Not varsa prompt'a ekle
      String mealPrompt = tr(
        'meal_type',
        namedArgs: <String, String>{'meal': meal},
      );
      if (note != null && note.isNotEmpty) {
        mealPrompt = '$mealPrompt. Not: $note';
      }

      final List<RecipeSuggestion> suggestions = await openAI.suggestRecipes(
        ings,
        servings: prefs.servings,
        query: prefs.composePrompt(mealPrompt),
        excludeTitles: _seenTitles.toList(),
      );

      // Görselleri düzelt - imageService kullan
      final List<Recipe> recipes = await Future.wait(
        suggestions.map((RecipeSuggestion e) async {
          final String? imageUrl = await imageService.fixImageUrl(
            e.imageUrl,
            e.title,
          );

          return Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: e.steps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: imageUrl,
            category: e.category ?? meal,
            fiber: e.fiber,
          );
        }),
      );

      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      // Cache'e kaydet (meal bazlı) - cacheService kullan
      final String cacheKey = cacheService.getMealCacheKey(userId, meal);
      await cacheService.addRecipesToCache(cacheKey, recipes);

      // UserRecipeService'e de kaydet - userRecipeRepository kullan
      try {
        final List<UserRecipe> existingRecipes = userRecipeRepository.fetch();
        final Set<String> existingTitles = existingRecipes
            .map((UserRecipe r) => r.title)
            .toSet();

        for (final Recipe recipe in recipes) {
          if (existingTitles.contains(recipe.title)) {
            continue;
          }

          final UserRecipe userRecipe = UserRecipe(
            id: const Uuid().v4(),
            title: recipe.title,
            description: '',
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            imagePath: recipe.imageUrl,
            tags: recipe.category != null
                ? <String>[recipe.category!]
                : <String>[],
            isAIRecommendation: true,
            createdAt: DateTime.now(),
          );

          await userRecipeRepository.addRecipe(userRecipe);
        }
      } on Exception catch (e) {
        debugPrint('[RecipesCubit] Hive kaydetme hatası: $e');
      }

      await promptPreferences.incrementGenerated(recipes.length);
      if (!isClosed) {
        emit(RecipesLoaded(recipes, allRecipes: recipes));
      }
    } on Exception catch (e) {
      debugPrint('[RecipesCubit] loadWithSelection hatası: $e');
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
            imageUrl: await imageService.fixImageUrl(e.imageUrl, e.title),
          ),
        ),
      );
      await promptPreferences.incrementGenerated(recipes.length);
      emit(RecipesLoaded(recipes, allRecipes: recipes));
    } on Exception catch (e) {
      if (isClosed) {
        return;
      }
      emit(RecipesFailure(e.toString()));
    }
  }

  Future<void> loadFromCache(String userId) async {
    debugPrint('[RecipesCubit] loadFromCache başladı - userId: $userId');
    // Kategoriye göre yükle
    await _loadCategory(_currentCategory, userId);
  }

  Future<void> loadCategory(
    String category,
    String userId, {
    String? meal,
  }) async {
    _currentCategory = category;
    _selectedMeal = meal;
    await _loadCategory(category, userId);
  }

  Future<void> _loadCategory(String category, String userId) async {
    debugPrint('[RecipesCubit] Kategori yükleniyor: $category');
    emit(const RecipesLoading());

    try {
      List<Recipe> recipes = <Recipe>[];

      switch (category) {
        case 'favorites':
          recipes = await _loadFavorites();
          break;
        case 'made_recipes':
          recipes = await _loadMadeRecipes();
          break;
        case 'shared_recipes':
          recipes = await _loadSharedRecipes();
          break;
        case 'suggestions':
        default:
          // Öğün bazlı öneriler - cache'den yükle veya yeni veri çek
          recipes = await _loadSuggestions(userId);
          break;
      }

      if (!isClosed) {
        debugPrint('[RecipesCubit] Kategori yüklendi: ${recipes.length} tarif');
        emit(RecipesLoaded(recipes, allRecipes: recipes));
      }
    } on Exception catch (e) {
      debugPrint('[RecipesCubit] Kategori yükleme hatası: $e');
      if (!isClosed) {
        emit(RecipesFailure(e.toString()));
      }
    }
  }

  Future<List<Recipe>> _loadFavorites() async {
    final Box<dynamic> favoritesBox = Hive.isBoxOpen('favorite_recipes')
        ? Hive.box<dynamic>('favorite_recipes')
        : await Hive.openBox<dynamic>('favorite_recipes');

    final List<Recipe> favorites = favoritesBox.values.map<Recipe>((
      Object? value,
    ) {
      final Map<dynamic, dynamic>? map = value as Map<dynamic, dynamic>?;
      if (map == null) {
        return const Recipe(
          id: '',
          title: '',
          ingredients: <String>[],
          steps: <String>[],
        );
      }
      return Recipe.fromMap(map);
    }).toList();

    debugPrint('[RecipesCubit] ${favorites.length} favori tarif bulundu');
    return favorites;
  }

  Future<List<Recipe>> _loadSuggestions(String userId) async {
    // Genel öneriler için load() metodunu kullan
    // Meal bazlı cache loadMeal metodunda yönetiliyor
    await load(userId);
    final RecipesState state = this.state;
    if (state is RecipesLoaded) {
      List<Recipe> allRecipes = state.recipes;

      // Öğün bazlı filtreleme
      if (_selectedMeal != null && _selectedMeal!.isNotEmpty) {
        allRecipes = allRecipes
            .where(
              (Recipe r) =>
                  r.category?.toLowerCase() == _selectedMeal!.toLowerCase(),
            )
            .toList();
      }

      return allRecipes;
    }
    return <Recipe>[];
  }

  /// Load recipes for a specific meal - ayrı istek atar ve cache'e kaydeder
  Future<List<Recipe>> loadMeal(String userId, String meal) async {
    // Meal bazlı cache key
    final String cacheKey = cacheService.getMealCacheKey(userId, meal);

    // Cache kontrolü
    final List<Map<String, Object?>>? cachedRecipes = cacheService.getRecipes(
      cacheKey,
    );

    if (cachedRecipes != null && cachedRecipes.isNotEmpty) {
      // Cache'den okunan tarifleri Recipe'e dönüştür
      final List<Recipe> cachedRecipesList = RecipeMapper.fromMapList(
        cachedRecipes,
        defaultCategory: meal,
      );

      // Görselleri düzelt (eğer boşsa) - imageService kullan
      final List<Recipe> recipesWithImages = await imageService.fixImageUrls(
        cachedRecipesList,
        (Recipe r) => r.title,
        (Recipe r) => r.imageUrl,
        (Recipe r, String? newUrl) => Recipe(
          id: r.id,
          title: r.title,
          ingredients: r.ingredients,
          steps: r.steps,
          calories: r.calories,
          durationMinutes: r.durationMinutes,
          difficulty: r.difficulty,
          imageUrl: newUrl,
          category: r.category,
          fiber: r.fiber,
        ),
      );

      return recipesWithImages;
    }

    // Cache boşsa yeni istek at
    debugPrint('[RecipesCubit] Cache boş, meal bazlı istek atılıyor: $meal');
    // NOT: emit etmiyoruz çünkü bu sadece bir meal için yükleme
    // UI loading state'i recipes_page'de yönetiliyor

    try {
      final PromptPreferences prefs = promptPreferences.getPreferences();

      // Pantry items'ı al
      final List<dynamic> pantryItemsRaw = await sl<IPantryRepository>()
          .getItems(userId: userId);
      final List<PantryItem> pantryItems = pantryItemsRaw.cast<PantryItem>();
      final List<Ingredient> ingredients = pantryItems
          .map<Ingredient>(
            (PantryItem i) =>
                Ingredient(name: i.name, unit: i.unit, quantity: i.quantity),
          )
          .toList();

      // Meal bazlı prompt oluştur
      final String mealName = MealNameMapper.getMealName(meal);
      final String mealPrompt = tr(
        'meal_type',
        namedArgs: <String, String>{'meal': mealName},
      );
      final String contextPrompt = prefs.composePrompt(
        '${tr('pantry_ingredients_prompt', namedArgs: <String, String>{'ingredients': ingredients.map((Ingredient e) => e.name).join(', ')})} $mealPrompt',
      );

      // OpenAI'ye meal bazlı istek at
      final List<RecipeSuggestion> suggestions = await openAI.suggestRecipes(
        ingredients,
        servings: prefs.servings,
        count: 6, // Her meal için 6 tarif
        query: contextPrompt,
        excludeTitles: _seenTitles.toList(),
      );

      // Recipe'lere dönüştür ve görselleri düzelt - imageService kullan
      final List<Recipe> recipes = await Future.wait(
        suggestions.map((RecipeSuggestion e) async {
          final String? imageUrl = await imageService.fixImageUrl(
            e.imageUrl,
            e.title,
          );
          return Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: e.steps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: imageUrl,
            category: e.category ?? meal,
            fiber: e.fiber,
          );
        }),
      );

      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      // Cache'e kaydet - cacheService kullan
      await cacheService.saveRecipes(cacheKey, recipes);

      // Yeni tarifleri UserRecipeService'e kaydet (Hive'a) - userRecipeRepository kullan
      try {
        final List<UserRecipe> existingRecipes = userRecipeRepository.fetch();
        final Set<String> existingTitles = existingRecipes
            .map((UserRecipe r) => r.title)
            .toSet();

        for (final Recipe recipe in recipes) {
          // Duplicate kontrolü
          if (existingTitles.contains(recipe.title)) {
            continue;
          }

          // UserRecipe oluştur ve kaydet
          final UserRecipe userRecipe = UserRecipe(
            id: const Uuid().v4(),
            title: recipe.title,
            description: '',
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            imagePath: recipe.imageUrl,
            tags: recipe.category != null
                ? <String>[recipe.category!]
                : <String>[],
            isAIRecommendation: true,
            createdAt: DateTime.now(),
          );

          await userRecipeRepository.addRecipe(userRecipe);
        }
      } on Exception catch (e) {
        debugPrint(
          '[RecipesCubit] UserRecipeRepository\'e kaydetme hatası (meal: $meal): $e',
        );
        // Hata olsa bile devam et
      }

      await promptPreferences.incrementGenerated(recipes.length);

      // NOT: emit etmiyoruz çünkü bu sadece bir meal için yükleme
      // UI güncellemesi recipes_page'deki _loadAllData tarafından yapılacak

      return recipes;
    } on Exception catch (e) {
      debugPrint('[RecipesCubit] loadMeal hatası (meal: $meal): $e');
      if (!isClosed) {
        emit(RecipesFailure(e.toString()));
      }
      return <Recipe>[];
    }
  }

  /// Load more recipes for a specific meal - bypasses cache and requests new recipes
  /// Excludes already loaded recipe titles to get different recipes
  Future<List<Recipe>> loadMoreMealRecipes(
    String userId,
    String meal,
    List<String> excludeTitles,
  ) async {
    debugPrint(
      '[RecipesCubit] loadMoreMealRecipes başladı - userId: $userId, meal: $meal, excludeTitles: ${excludeTitles.length}',
    );

    try {
      final PromptPreferences prefs = promptPreferences.getPreferences();

      // Pantry items'ı al
      final List<dynamic> pantryItemsRaw = await sl<IPantryRepository>()
          .getItems(userId: userId);
      final List<PantryItem> pantryItems = pantryItemsRaw.cast<PantryItem>();
      final List<Ingredient> ingredients = pantryItems
          .map<Ingredient>(
            (PantryItem i) =>
                Ingredient(name: i.name, unit: i.unit, quantity: i.quantity),
          )
          .toList();

      // Meal bazlı prompt oluştur
      final String mealName = MealNameMapper.getMealName(meal);
      final String mealPrompt = tr(
        'meal_type',
        namedArgs: <String, String>{'meal': mealName},
      );
      final String contextPrompt = prefs.composePrompt(
        '${tr('pantry_ingredients_prompt', namedArgs: <String, String>{'ingredients': ingredients.map((Ingredient e) => e.name).join(', ')})} $mealPrompt',
      );

      // Mevcut tariflerin başlıklarını excludeTitles'a ekle
      final List<String> allExcludeTitles = <String>[
        ...excludeTitles,
        ..._seenTitles.toList(),
      ];

      // OpenAI'ye meal bazlı istek at
      final List<RecipeSuggestion> suggestions = await openAI.suggestRecipes(
        ingredients,
        servings: prefs.servings,
        count: 6, // Her meal için 6 tarif
        query: contextPrompt,
        excludeTitles: allExcludeTitles,
      );

      // Recipe'lere dönüştür ve görselleri düzelt - imageService kullan
      final List<Recipe> recipes = await Future.wait(
        suggestions.map((RecipeSuggestion e) async {
          final String? imageUrl = await imageService.fixImageUrl(
            e.imageUrl,
            e.title,
          );
          return Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: e.steps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: imageUrl,
            category: e.category ?? meal,
            fiber: e.fiber,
          );
        }),
      );

      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      // Cache'e kaydet (mevcut cache'e ekle) - cacheService kullan
      final String cacheKey = cacheService.getMealCacheKey(userId, meal);
      await cacheService.addRecipesToCache(cacheKey, recipes);

      // Yeni tarifleri UserRecipeService'e kaydet - userRecipeRepository kullan
      try {
        final List<UserRecipe> existingRecipes = userRecipeRepository.fetch();
        final Set<String> existingTitles = existingRecipes
            .map((UserRecipe r) => r.title)
            .toSet();

        for (final Recipe recipe in recipes) {
          // Duplicate kontrolü
          if (existingTitles.contains(recipe.title)) {
            continue;
          }

          // UserRecipe oluştur ve kaydet
          final UserRecipe userRecipe = UserRecipe(
            id: const Uuid().v4(),
            title: recipe.title,
            description: '',
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            imagePath: recipe.imageUrl,
            tags: recipe.category != null
                ? <String>[recipe.category!]
                : <String>[],
            isAIRecommendation: true,
            createdAt: DateTime.now(),
          );

          await userRecipeRepository.addRecipe(userRecipe);
        }
      } on Exception catch (e) {
        debugPrint(
          '[RecipesCubit] UserRecipeRepository\'e kaydetme hatası: $e',
        );
        // Hata olsa bile devam et
      }

      await promptPreferences.incrementGenerated(recipes.length);

      return recipes;
    } on Exception catch (e) {
      debugPrint('[RecipesCubit] loadMoreMealRecipes hatası (meal: $meal): $e');
      if (!isClosed) {
        emit(RecipesFailure(e.toString()));
      }
      return <Recipe>[];
    }
  }

  Future<List<Recipe>> _loadMadeRecipes() async {
    // imagePath olan tarifler = yapılmış tarifler
    final List<UserRecipe> userRecipes = userRecipeRepository
        .fetch()
        .where((UserRecipe r) => r.imagePath != null && r.imagePath!.isNotEmpty)
        .toList();

    final List<Recipe> recipes = userRecipes
        .map<Recipe>(
          (UserRecipe ur) => Recipe(
            id: ur.id,
            title: ur.title,
            ingredients: ur.ingredients,
            steps: ur.steps,
            imageUrl: ur.imagePath,
            category: ur.tags.isNotEmpty ? ur.tags.first : null,
          ),
        )
        .toList();

    debugPrint('[RecipesCubit] ${recipes.length} yapılmış tarif bulundu');
    return recipes;
  }

  Future<List<Recipe>> _loadSharedRecipes() async {
    // videoPath olan tarifler = paylaşılmış tarifler
    final List<UserRecipe> userRecipes = userRecipeRepository
        .fetch()
        .where((UserRecipe r) => r.videoPath != null && r.videoPath!.isNotEmpty)
        .toList();

    final List<Recipe> recipes = userRecipes
        .map<Recipe>(
          (UserRecipe ur) => Recipe(
            id: ur.id,
            title: ur.title,
            ingredients: ur.ingredients,
            steps: ur.steps,
            imageUrl: ur.imagePath,
            category: ur.tags.isNotEmpty ? ur.tags.first : null,
          ),
        )
        .toList();

    debugPrint('[RecipesCubit] ${recipes.length} paylaşılmış tarif bulundu');
    return recipes;
  }

  /// Apply client-side filter from UI without exposing emit
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

  /// Reset filters and show all recipes
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

  /// Discovery with infinite scroll
  Future<void> discoverInit(String userId, String query) async {
    _seenTitles.clear();
    emit(const RecipesLoading());
    await _discoverFetch(userId, query);
  }

  /// Load more recipes for discovery
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
            imageUrl: await imageService.fixImageUrl(e.imageUrl, e.title),
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
    } on Exception catch (e) {
      if (!isClosed) {
        emit(RecipesFailure(e.toString()));
      }
    }
  }

  /// Load more recipes from pantry for infinite scroll
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
            imageUrl: await imageService.fixImageUrl(e.imageUrl, e.title),
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
    } on Exception {
      // ignore fail silently for load more
      if (!isClosed) {
        emit(RecipesLoaded(current));
      }
    } finally {
      isFetchingMore = false;
      if (state is RecipesLoaded && !(state as RecipesLoaded).isLoadingMore) {
        debugPrint('[RecipesCubit] Load more finished.');
      }
    }
  }

  /// Deletes recipes from cache by their titles
  Future<void> deleteRecipesFromCache(
    String userId,
    String meal,
    List<String> titles,
  ) async {
    final String cacheKey = cacheService.getMealCacheKey(userId, meal);
    await cacheService.deleteRecipesByTitles(cacheKey, titles);
  }
}
