import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/core/utils/request_cancellation_helper.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_prompt_preference_service.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_user_recipe_repository.dart';
import 'package:smartdolap/features/recipes/data/services/meal_name_mapper.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_filter_service.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_mapper.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_step.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_cache_service.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_image_service.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/product/services/openai/openai_parsing_exception.dart';
import 'package:uuid/uuid.dart';

/// RecipesViewModel - Business logic orchestration for recipes feature.
///
/// Responsibilities:
/// - Execute use cases (_suggest, cache, user recipes, etc.)
/// - Coordinate OpenAI requests and Firestore/cache persistence
/// - Manage filtering, pagination, and discovery flows
/// - Update [RecipesCubit] with new states
///
/// SOLID Principles:
/// - Single Responsibility: Handles only business logic orchestration
/// - Open/Closed: Easily extendable with new recipe flows
/// - Interface Segregation: Depends on granular interfaces/use cases
/// - Dependency Inversion: Depends on abstractions, not concretions
class RecipesViewModel {
  RecipesViewModel({
    required RecipesCubit cubit,
    required SuggestRecipesFromPantry suggest,
    required IOpenAIService openAI,
    required IPromptPreferenceService promptPreferences,
    required IRecipeCacheService cacheService,
    required IRecipeImageService imageService,
    required IUserRecipeRepository userRecipeRepository,
    required IRecipesRepository recipesRepository,
    required IPantryRepository pantryRepository,
    RecipeFilterService? filterService,
  }) : _cubit = cubit,
       _suggest = suggest,
       _openAI = openAI,
       _promptPreferences = promptPreferences,
       _cacheService = cacheService,
       _imageService = imageService,
       _userRecipeRepository = userRecipeRepository,
       _recipesRepository = recipesRepository,
       _pantryRepository = pantryRepository,
       _filterService = filterService ?? RecipeFilterService();

  final RecipesCubit _cubit;
  final SuggestRecipesFromPantry _suggest;
  final IOpenAIService _openAI;
  final IPromptPreferenceService _promptPreferences;
  final IRecipeCacheService _cacheService;
  final IRecipeImageService _imageService;
  final IUserRecipeRepository _userRecipeRepository;
  final IRecipesRepository _recipesRepository;
  final IPantryRepository _pantryRepository;
  final RecipeFilterService _filterService;

  final Set<String> _seenTitles = <String>{};
  bool _isFetchingMore = false;
  String _currentCategory = 'suggestions';
  String? _selectedMeal;

  // Request cancellation helper for API calls
  final RequestCancellationHelper _cancellationHelper =
      RequestCancellationHelper();

  // ============================================================================
  // MEVCUT AKIŞ ANALİZİ - TARİF YÜKLEME VE KAYDETME SÜRECİ
  // ============================================================================
  //
  // 📋 GENEL AKIŞ ÖZETİ:
  //   1. OpenAI'den tarif önerileri çekiliyor
  //   2. Görseller düzeltiliyor (ImageLookupService ile)
  //   3. Tarifler cache'e (Hive) kaydediliyor
  //   4. Tarifler UserRecipeService'e (Hive) kaydediliyor
  //   5. SADECE load() metodu Firestore'a kaydediyor (diğerleri kaydetmiyor!)
  //
  // ⚠️ TUTARSIZLIK: loadMeal(), loadMoreMealRecipes(), loadWithSelection()
  //    Firestore'a kaydetmiyor, sadece Hive'a kaydediyor!
  // ============================================================================

  Future<void> load(String userId) async {
    _cubit.setLoading();
    try {
      // 🔄 AKIŞ 1: load() metodu
      //   1. _suggest() use case'i çağrılıyor (SuggestRecipesFromPantry)
      //   2. Bu use case RecipesRepositoryImpl.suggestFromPantry() çağırıyor
      //   3. Repository içinde:
      //      a) Pantry items yükleniyor
      //      b) OpenAI'ye istek atılıyor (_openai.suggestRecipes())
      //      c) Her tarif için görsel düzeltiliyor (ImageLookupService)
      //      d) Her tarif Firestore'a kaydediliyor (_firestore.collection('recipes').doc().set())
      //      e) Recipe objeleri oluşturulup döndürülüyor
      //   4. RecipesCubit'e Recipe listesi dönüyor
      //   5. State emit ediliyor (RecipesLoaded)
      //   6. PromptPreferences güncelleniyor (incrementGenerated)
      //
      // ✅ Firestore'a kaydediliyor: EVET
      // ✅ Hive cache'e kaydediliyor: HAYIR (sadece repository içinde Firestore'a kaydediliyor)
      // ✅ UserRecipeService'e kaydediliyor: HAYIR
      // _suggest() zaten görselleri düzeltiyor (RecipesRepository içinde)
      final List<Recipe> recipes = await _suggest(
        householdId: userId,
      ); // userId is actually householdId

      if (_cubit.isClosed) {
        return;
      }
      _cubit.setLoaded(recipes, allRecipes: recipes);
      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      // _promptPreferences.incrementGenerated kaldırıldı - repository içinde zaten güncelleniyor
    } on OpenAIParsingException catch (error, stackTrace) {
      Logger.error(
        '[RecipesCubit] OpenAI parsing error in load()',
        error,
        stackTrace,
      );
      if (_cubit.isClosed) {
        return;
      }
      _cubit.setFailure('openai_parse_error');
    } on Object catch (error, stackTrace) {
      Logger.error('[RecipesCubit] load error', error, stackTrace);
      if (_cubit.isClosed) {
        return;
      }
      _cubit.setFailure('unknown_error');
    }
  }

  Future<void> loadWithSelection(
    String userId,
    List<String> names,
    String meal, {
    String? note,
  }) async {
    _cubit.setLoading();
    try {
      // 🔄 AKIŞ 2: loadWithSelection() metodu (Öneri Al sayfasından)
      //   1. Seçilen malzemeler Ingredient listesine dönüştürülüyor
      //   2. Meal prompt'u oluşturuluyor (not varsa ekleniyor)
      //   3. OpenAI'ye direkt istek atılıyor (_openAI.suggestRecipes())
      //   4. Her tarif için görsel düzeltiliyor (_imageService.fixImageUrl())
      //   5. Recipe objeleri oluşturuluyor
      //   6. Cache'e kaydediliyor (meal bazlı cache key ile)
      //   7. UserRecipeService'e kaydediliyor (Hive'a, duplicate kontrolü ile)
      //   8. State emit ediliyor
      //
      // ❌ Firestore'a kaydediliyor: HAYIR
      // ✅ Hive cache'e kaydediliyor: EVET (_cacheService.addRecipesToCache)
      // ✅ UserRecipeService'e kaydediliyor: EVET (_userRecipeRepository.addRecipe)
      final PromptPreferences prefs = _promptPreferences.getPreferences();
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

      // 🔄 YENİ AKIŞ: Firestore-önce, sonra OpenAI mantığı
      // Repository helper'ı kullanarak önce Firestore'dan oku, eksik kalanı OpenAI ile tamamla
      final List<Recipe> recipes = await _recipesRepository
          .getRecipesFromFirestoreFirst(
            userId: userId,
            meal: meal,
            ingredients: ings,
            prompt: prefs.composePrompt(mealPrompt),
            targetCount: 6,
            excludeTitles: _seenTitles.toList(),
          );

      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      // Cache'e kaydet (meal bazlı) - _cacheService kullan
      final String cacheKey = _cacheService.getMealCacheKey(userId, meal);
      await _cacheService.addRecipesToCache(cacheKey, recipes);

      // UserRecipeService'e de kaydet - _userRecipeRepository kullan
      try {
        final List<UserRecipe> existingRecipes = _userRecipeRepository.fetch();
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
            ingredients: recipe.ingredients,
            steps:
                recipe.stepsAsStrings, // Convert RecipeStep list to String list
            imagePath: recipe.imageUrl,
            tags: recipe.category != null
                ? <String>[recipe.category!]
                : <String>[],
            isAIRecommendation: true,
            createdAt: DateTime.now(),
          );

          await _userRecipeRepository.addRecipe(userRecipe);
        }
      } on Exception catch (e) {
        debugPrint('[RecipesCubit] Hive kaydetme hatası: $e');
      }

      // _promptPreferences.incrementGenerated kaldırıldı - repository içinde zaten güncelleniyor
      if (!_cubit.isClosed) {
        _cubit.setLoaded(recipes, allRecipes: recipes);
      }
    } on Exception catch (e) {
      debugPrint('[RecipesCubit] loadWithSelection hatası: $e');
      if (!_cubit.isClosed) {
        _cubit.setFailure(e.toString());
      }
    }
  }

  Future<void> loadFromText(String csv) async {
    _cubit.setLoading();
    try {
      final PromptPreferences prefs = _promptPreferences.getPreferences();
      final List<Ingredient> ings = csv
          .split(',')
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .map((String s) => Ingredient(name: s))
          .toList();
      // Get cancellation token for this request
      final CancelToken cancelToken = _cancellationHelper.getToken(
        'loadWithSelection',
      );

      final List<RecipeSuggestion> suggestions = await _openAI.suggestRecipes(
        ings,
        servings: prefs.servings,
        query: prefs.composePrompt(tr('free_input_list')),
        cancelToken: cancelToken,
      );
      if (_cubit.isClosed) {
        return;
      }
      final List<Recipe> recipes = await Future.wait(
        suggestions.map((RecipeSuggestion e) async {
          // Convert String steps to RecipeStep list
          final List<RecipeStep> recipeSteps = e.steps
              .map(RecipeStep.fromString)
              .toList();

          return Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: recipeSteps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: await _imageService.fixImageUrl(
              e.imageUrl,
              e.title,
              imageSearchQuery: e.imageSearchQuery,
            ),
          );
        }),
      );
      await _promptPreferences.incrementGenerated(recipes.length);
      _cubit.setLoaded(recipes, allRecipes: recipes);
    } on Exception catch (e) {
      if (_cubit.isClosed) {
        return;
      }
      _cubit.setFailure(e.toString());
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
    _cubit.setLoading();

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

      if (!_cubit.isClosed) {
        debugPrint('[RecipesCubit] Kategori yüklendi: ${recipes.length} tarif');
        _cubit.setLoaded(recipes, allRecipes: recipes);
      }
    } on Exception catch (e) {
      debugPrint('[RecipesCubit] Kategori yükleme hatası: $e');
      if (!_cubit.isClosed) {
        _cubit.setFailure(e.toString());
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
          steps: <RecipeStep>[],
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
    final RecipesState state = _cubit.currentState;
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

  /// Load recipes for a specific meal - Hive → Firestore → AI priority
  Future<List<Recipe>> loadMeal(String userId, String meal) async {
    debugPrint(
      '[RecipesCubit] loadMeal başladı - userId: $userId, meal: $meal',
    );

    // Meal bazlı cache key
    final String cacheKey = _cacheService.getMealCacheKey(userId, meal);

    // 1. ÖNCE HIVE CACHE'DEN KONTROL ET
    final List<Map<String, Object?>>? cachedRecipes = _cacheService.getRecipes(
      cacheKey,
    );

    if (cachedRecipes != null && cachedRecipes.isNotEmpty) {
      debugPrint(
        "[RecipesCubit] Cache'den ${cachedRecipes.length} tarif bulundu (meal: $meal)",
      );

      // Cache'den okunan tarifleri Recipe'e dönüştür
      final List<Recipe> cachedRecipesList = RecipeMapper.fromMapList(
        cachedRecipes,
        defaultCategory: meal,
      );

      // Görselleri düzelt (eğer boşsa) - _imageService kullan
      final List<Recipe> recipesWithImages = await _imageService.fixImageUrls(
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

      // Cache'den yeterli tarif varsa direkt döndür, API çağrısı yapma
      if (recipesWithImages.length >= 3) {
        debugPrint(
          "[RecipesCubit] Cache'den yeterli tarif var (${recipesWithImages.length}), API çağrısı yapılmıyor",
        );
        // Arka planda sync yapma - cache yeterli, gereksiz API çağrısı yapma
        // Sadece kullanıcı açıkça "daha fazla yükle" derse sync yapılabilir
        return recipesWithImages;
      }

      // Cache'de az tarif varsa Firestore → AI akışına devam et
      debugPrint(
        "[RecipesCubit] Cache'de yetersiz tarif var (${recipesWithImages.length}/3), Firestore → AI akışına devam ediliyor",
      );
    }

    // 2. HIVE BOŞ VEYA YETERSİZSE FIRESTORE → AI AKIŞI
    debugPrint(
      '[RecipesCubit] Cache boş, Firestore → AI akışı başlatılıyor (meal: $meal)',
    );

    try {
      final PromptPreferences prefs = _promptPreferences.getPreferences();

      // Pantry items'ı al
      final List<dynamic> pantryItemsRaw = await _pantryRepository.getItems(
        householdId: userId,
      ); // userId is actually householdId
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

      // 🔄 YENİ AKIŞ: Hive → Firestore → AI mantığı
      final List<Recipe> recipes = await _recipesRepository
          .getRecipesFromFirestoreFirst(
            userId: userId,
            meal: meal,
            ingredients: ingredients,
            prompt: contextPrompt,
            targetCount: 6,
            excludeTitles: _seenTitles.toList(),
          );

      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      // Cache'e kaydet - _cacheService kullan
      if (recipes.isNotEmpty) {
        await _cacheService.addRecipesToCache(cacheKey, recipes);
      }

      // Yeni tarifleri UserRecipeService'e kaydet - _userRecipeRepository kullan
      try {
        final List<UserRecipe> existingRecipes = _userRecipeRepository.fetch();
        final Set<String> existingTitles = existingRecipes
            .map((UserRecipe r) => r.title)
            .toSet();

        for (final Recipe recipe in recipes) {
          if (!existingTitles.contains(recipe.title)) {
            await _userRecipeRepository.addRecipe(
              UserRecipe(
                id: const Uuid().v4(),
                title: recipe.title,
                ingredients: recipe.ingredients,
                steps: recipe
                    .stepsAsStrings, // Convert RecipeStep list to String list
                imagePath: recipe.imageUrl,
                tags: <String>[meal],
                isAIRecommendation: true,
                createdAt: DateTime.now(),
              ),
            );
          }
        }
      } on Object catch (error) {
        debugPrint(
          '[RecipesCubit] UserRecipeService kaydetme hatası (meal: $meal): $error',
        );
      }

      debugPrint(
        '[RecipesCubit] loadMeal tamamlandı - ${recipes.length} tarif (meal: $meal)',
      );
      return recipes;
    } on Object catch (error) {
      debugPrint('[RecipesCubit] loadMeal hatası (meal: $meal): $error');
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
    // 🔄 AKIŞ 4: loadMoreMealRecipes() metodu (Daha fazla yükle butonu)
    //   1. Cache bypass ediliyor (direkt OpenAI'ye istek)
    //   2. Pantry items yükleniyor
    //   3. Meal bazlı prompt oluşturuluyor
    //   4. Mevcut tarif başlıkları excludeTitles'a ekleniyor
    //   5. OpenAI'ye istek atılıyor (excludeTitles ile)
    //   6. Her tarif için görsel düzeltiliyor
    //   7. Recipe objeleri oluşturuluyor
    //   8. Cache'e ekleniyor (mevcut cache'e ekleme - addRecipesToCache)
    //   9. UserRecipeService'e kaydediliyor (Hive'a)
    //   10. Döndürülüyor
    //
    // ❌ Firestore'a kaydediliyor: HAYIR
    // ✅ Hive cache'e kaydediliyor: EVET (_cacheService.addRecipesToCache)
    // ✅ UserRecipeService'e kaydediliyor: EVET (_userRecipeRepository.addRecipe)
    debugPrint(
      '[RecipesCubit] loadMoreMealRecipes başladı - userId: $userId, meal: $meal, excludeTitles: ${excludeTitles.length}',
    );

    try {
      final PromptPreferences prefs = _promptPreferences.getPreferences();

      // Pantry items'ı al
      final List<dynamic> pantryItemsRaw = await _pantryRepository.getItems(
        householdId: userId,
      ); // userId is actually householdId
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
        ..._seenTitles,
      ];

      // 🔄 YENİ AKIŞ: Firestore-önce, sonra OpenAI mantığı
      // Repository helper'ı kullanarak önce Firestore'dan oku, eksik kalanı OpenAI ile tamamla
      final List<Recipe> recipes = await _recipesRepository
          .getRecipesFromFirestoreFirst(
            userId: userId,
            meal: meal,
            ingredients: ingredients,
            prompt: contextPrompt,
            targetCount: 6,
            excludeTitles: allExcludeTitles,
          );

      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      // Cache'e kaydet (mevcut cache'e ekle) - _cacheService kullan
      final String cacheKey = _cacheService.getMealCacheKey(userId, meal);
      await _cacheService.addRecipesToCache(cacheKey, recipes);

      // Yeni tarifleri UserRecipeService'e kaydet - _userRecipeRepository kullan
      try {
        final List<UserRecipe> existingRecipes = _userRecipeRepository.fetch();
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
            ingredients: recipe.ingredients,
            steps:
                recipe.stepsAsStrings, // Convert RecipeStep list to String list
            imagePath: recipe.imageUrl,
            tags: recipe.category != null
                ? <String>[recipe.category!]
                : <String>[],
            isAIRecommendation: true,
            createdAt: DateTime.now(),
          );

          await _userRecipeRepository.addRecipe(userRecipe);
        }
      } on Object catch (error) {
        debugPrint(
          "[RecipesCubit] UserRecipeRepository'e kaydetme hatası: $error",
        );
        // Hata olsa bile devam et
      }

      // _promptPreferences.incrementGenerated kaldırıldı - repository içinde zaten güncelleniyor

      return recipes;
    } on Object catch (error) {
      debugPrint(
        '[RecipesCubit] loadMoreMealRecipes hatası (meal: $meal): $error',
      );
      if (!_cubit.isClosed) {
        _cubit.setFailure(error.toString());
      }
      return <Recipe>[];
    }
  }

  Future<List<Recipe>> _loadMadeRecipes() async {
    // imagePath olan tarifler = yapılmış tarifler
    final List<UserRecipe> userRecipes = _userRecipeRepository
        .fetch()
        .where((UserRecipe r) => r.imagePath != null && r.imagePath!.isNotEmpty)
        .toList();

    final List<Recipe> recipes = userRecipes.map<Recipe>((UserRecipe ur) {
      // Convert String steps to RecipeStep list
      final List<RecipeStep> recipeSteps = ur.steps
          .map(RecipeStep.fromString)
          .toList();

      return Recipe(
        id: ur.id,
        title: ur.title,
        ingredients: ur.ingredients,
        steps: recipeSteps,
        imageUrl: ur.imagePath,
        category: ur.tags.isNotEmpty ? ur.tags.first : null,
      );
    }).toList();

    debugPrint('[RecipesCubit] ${recipes.length} yapılmış tarif bulundu');
    return recipes;
  }

  Future<List<Recipe>> _loadSharedRecipes() async {
    // videoPath olan tarifler = paylaşılmış tarifler
    final List<UserRecipe> userRecipes = _userRecipeRepository
        .fetch()
        .where((UserRecipe r) => r.videoPath != null && r.videoPath!.isNotEmpty)
        .toList();

    final List<Recipe> recipes = userRecipes.map<Recipe>((UserRecipe ur) {
      // Convert String steps to RecipeStep list
      final List<RecipeStep> recipeSteps = ur.steps
          .map(RecipeStep.fromString)
          .toList();

      return Recipe(
        id: ur.id,
        title: ur.title,
        ingredients: ur.ingredients,
        steps: recipeSteps,
        imageUrl: ur.imagePath,
        category: ur.tags.isNotEmpty ? ur.tags.first : null,
      );
    }).toList();

    debugPrint('[RecipesCubit] ${recipes.length} paylaşılmış tarif bulundu');
    return recipes;
  }

  /// Apply client-side filter from UI without exposing emit
  /// Filter logic is delegated to RecipeFilterService (SRP)
  void applyFilter({
    List<String>? ingredients,
    String? meal,
    int? maxCalories,
    int? minFiber,
  }) {
    final RecipesState s = _cubit.currentState;
    if (s is! RecipesLoaded) {
      return;
    }
    final List<Recipe> source = s.allRecipes ?? s.recipes;

    // Update filters in filter service
    if (maxCalories != null) {
      _filterService.setFilter('maxCalories', maxCalories);
    }
    if (minFiber != null) {
      _filterService.setFilter('minFiber', minFiber);
    }
    if (meal != null && meal.isNotEmpty) {
      _filterService.setFilter('meal', meal);
    }
    if (ingredients != null && ingredients.isNotEmpty) {
      _filterService.setFilter('ingredients', ingredients);
    }

    // Apply filters using filter service
    List<Recipe> filtered = _filterService.applyFilters(source);

    // Apply ingredient filter manually (not yet in filter service)
    if (ingredients != null && ingredients.isNotEmpty) {
      filtered = filtered
          .where(
            (Recipe r) => ingredients.every(
              (String name) => r.ingredients
                  .map((String e) => e.toLowerCase())
                  .contains(name.toLowerCase()),
            ),
          )
          .toList();
    }

    // Apply meal filter manually (not yet in filter service)
    if (meal != null && meal.isNotEmpty) {
      filtered = filtered
          .where(
            (Recipe r) =>
                (r.category ?? '').toLowerCase() == meal.toLowerCase(),
          )
          .toList();
    }

    _cubit.setLoaded(
      filtered,
      allRecipes: source,
      activeFilters: _filterService.activeFilters,
    );
  }

  /// Reset filters and show all recipes
  /// Filter logic is delegated to RecipeFilterService (SRP)
  void resetFilters() {
    final RecipesState s = _cubit.currentState;
    if (s is! RecipesLoaded) {
      return;
    }
    _filterService.clearFilters();
    _cubit.setLoaded(
      s.allRecipes ?? s.recipes,
      allRecipes: s.allRecipes ?? s.recipes,
      activeFilters: const <String, dynamic>{},
    );
  }

  /// Discovery with infinite scroll
  Future<void> discoverInit(String userId, String query) async {
    _seenTitles.clear();
    _cubit.setLoading();
    await _discoverFetch(userId, query);
  }

  /// Load more recipes for discovery
  Future<void> discoverMore(String userId, String query) =>
      _discoverFetch(userId, query);

  Future<void> _discoverFetch(String userId, String query) async {
    final PromptPreferences prefs = _promptPreferences.getPreferences();
    try {
      final RecipesState currentState = _cubit.currentState;
      final List<Recipe> current = currentState is RecipesLoaded
          ? currentState.recipes
          : <Recipe>[];
      final List<Recipe> newOnes = await Future.wait(
        (await _openAI.suggestRecipes(
          <Ingredient>[],
          query: prefs.composePrompt(query),
          excludeTitles: _seenTitles.toList(),
          servings: prefs.servings,
          cancelToken: _cancellationHelper.getToken('discoverMore'),
        )).map((RecipeSuggestion e) async {
          // Convert String steps to RecipeStep list
          final List<RecipeStep> recipeSteps = e.steps
              .map(RecipeStep.fromString)
              .toList();

          return Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: recipeSteps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: await _imageService.fixImageUrl(
              e.imageUrl,
              e.title,
              imageSearchQuery: e.imageSearchQuery,
            ),
            category: e.category,
          );
        }),
      );
      _seenTitles.addAll(newOnes.map((Recipe e) => e.title));
      await _promptPreferences.incrementGenerated(newOnes.length);
      final List<Recipe> updated = <Recipe>[...current, ...newOnes];
      _cubit.setLoaded(
        updated,
        allRecipes: updated,
        activeFilters: _filterService.activeFilters,
      );
    } on Exception catch (e) {
      if (!_cubit.isClosed) {
        _cubit.setFailure(e.toString());
      }
    }
  }

  /// Load more recipes from pantry for infinite scroll
  Future<void> loadMoreFromPantry(String userId) async {
    if (_isFetchingMore) {
      return;
    }
    final RecipesState s = _cubit.currentState;
    final List<Recipe> current = s is RecipesLoaded ? s.recipes : <Recipe>[];
    final PromptPreferences prefs = _promptPreferences.getPreferences();
    try {
      _isFetchingMore = true;
      _cubit.setLoaded(current, isLoadingMore: true);
      debugPrint('[RecipesCubit] Loading more pantry suggestions...');
      final List<RecipeSuggestion> more = await _openAI.suggestRecipes(
        <Ingredient>[],
        servings: prefs.servings,
        query: prefs.composePrompt(tr('free_discovery')),
        excludeTitles: _seenTitles.toList(),
        cancelToken: _cancellationHelper.getToken('loadMoreFromPantry'),
      );
      final List<Recipe> mapped = await Future.wait(
        more.map((RecipeSuggestion e) async {
          // Convert String steps to RecipeStep list
          final List<RecipeStep> recipeSteps = e.steps
              .map(RecipeStep.fromString)
              .toList();

          return Recipe(
            id: '',
            title: e.title,
            ingredients: e.ingredients,
            steps: recipeSteps,
            calories: e.calories,
            durationMinutes: e.durationMinutes,
            difficulty: e.difficulty,
            imageUrl: await _imageService.fixImageUrl(
              e.imageUrl,
              e.title,
              imageSearchQuery: e.imageSearchQuery,
            ),
            category: e.category,
          );
        }),
      );
      _seenTitles.addAll(mapped.map((Recipe e) => e.title));
      await _promptPreferences.incrementGenerated(mapped.length);
      final List<Recipe> updated = <Recipe>[...current, ...mapped];
      _cubit.setLoaded(
        updated,
        allRecipes: updated,
        activeFilters: _filterService.activeFilters,
      );
    } on Exception {
      // ignore fail silently for load more
      if (!_cubit.isClosed) {
        _cubit.setLoaded(current);
      }
    } finally {
      _isFetchingMore = false;
      final RecipesState latest = _cubit.currentState;
      if (latest is RecipesLoaded && !latest.isLoadingMore) {
        debugPrint('[RecipesCubit] Load more finished.');
      }
    }
  }

  /// Dispose resources when view model is no longer needed.
  void dispose() {
    _cancellationHelper.dispose();
  }

  /// Deletes recipes from cache by their titles
  Future<void> deleteRecipesFromCache(
    String userId,
    String meal,
    List<String> titles,
  ) async {
    final String cacheKey = _cacheService.getMealCacheKey(userId, meal);
    await _cacheService.deleteRecipesByTitles(cacheKey, titles);
  }
}
