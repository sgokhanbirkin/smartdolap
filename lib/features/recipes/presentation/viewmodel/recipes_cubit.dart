import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/logger.dart';
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
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/product/services/openai/openai_parsing_exception.dart';
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
    required this.recipesRepository,
  }) : super(const RecipesInitial());

  final SuggestRecipesFromPantry suggest;
  final IOpenAIService openAI;
  final PromptPreferenceService promptPreferences;
  final ImageLookupService imageLookup;
  final RecipeCacheService cacheService;
  final RecipeImageService imageService;
  final IUserRecipeRepository userRecipeRepository;
  final IRecipesRepository recipesRepository;

  final Set<String> _seenTitles = <String>{};
  bool isFetchingMore = false;
  Map<String, dynamic> _activeFilters = <String, dynamic>{};
  String _currentCategory = 'suggestions';
  String? _selectedMeal;

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
    emit(const RecipesLoading());
    try {
      // 🔄 AKIŞ 1: load() metodu
      //   1. suggest() use case'i çağrılıyor (SuggestRecipesFromPantry)
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
      // suggest() zaten görselleri düzeltiyor (RecipesRepository içinde)
      final List<Recipe> recipes = await suggest(userId: userId);

      if (isClosed) {
        return;
      }
      emit(RecipesLoaded(recipes, allRecipes: recipes));
      _seenTitles.addAll(recipes.map((Recipe e) => e.title));

      // promptPreferences.incrementGenerated kaldırıldı - repository içinde zaten güncelleniyor
    } on OpenAIParsingException catch (e) {
      Logger.error('[RecipesCubit] OpenAI parsing error in load()', e);
      if (isClosed) {
        return;
      }
      emit(const RecipesFailure('openai_parse_error'));
    } catch (e, s) {
      Logger.error('[RecipesCubit] load error', e, s);
      if (isClosed) {
        return;
      }
      emit(const RecipesFailure('unknown_error'));
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
      // 🔄 AKIŞ 2: loadWithSelection() metodu (Öneri Al sayfasından)
      //   1. Seçilen malzemeler Ingredient listesine dönüştürülüyor
      //   2. Meal prompt'u oluşturuluyor (not varsa ekleniyor)
      //   3. OpenAI'ye direkt istek atılıyor (openAI.suggestRecipes())
      //   4. Her tarif için görsel düzeltiliyor (imageService.fixImageUrl())
      //   5. Recipe objeleri oluşturuluyor
      //   6. Cache'e kaydediliyor (meal bazlı cache key ile)
      //   7. UserRecipeService'e kaydediliyor (Hive'a, duplicate kontrolü ile)
      //   8. State emit ediliyor
      //
      // ❌ Firestore'a kaydediliyor: HAYIR
      // ✅ Hive cache'e kaydediliyor: EVET (cacheService.addRecipesToCache)
      // ✅ UserRecipeService'e kaydediliyor: EVET (userRecipeRepository.addRecipe)
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

      // 🔄 YENİ AKIŞ: Firestore-önce, sonra OpenAI mantığı
      // Repository helper'ı kullanarak önce Firestore'dan oku, eksik kalanı OpenAI ile tamamla
      final List<Recipe> recipes = await recipesRepository
          .getRecipesFromFirestoreFirst(
            userId: userId,
            meal: meal,
            ingredients: ings,
            prompt: prefs.composePrompt(mealPrompt),
            targetCount: 6,
            excludeTitles: _seenTitles.toList(),
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

      // promptPreferences.incrementGenerated kaldırıldı - repository içinde zaten güncelleniyor
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
    // 🔄 AKIŞ 3: loadMeal() metodu (Yapabileceklerin sayfası - meal bazlı)
    //   1. Meal bazlı cache key oluşturuluyor
    //   2. Cache kontrolü yapılıyor (cacheService.getRecipes())
    //   3. Eğer cache'de varsa:
    //      a) Cache'den okunuyor
    //      b) Recipe objelerine dönüştürülüyor
    //      c) Görseller düzeltiliyor (boşsa)
    //      d) Döndürülüyor
    //   4. Eğer cache boşsa:
    //      a) Pantry items yükleniyor
    //      b) Meal bazlı prompt oluşturuluyor
    //      c) OpenAI'ye istek atılıyor (openAI.suggestRecipes())
    //      d) Her tarif için görsel düzeltiliyor (imageService.fixImageUrl())
    //      e) Recipe objeleri oluşturuluyor
    //      f) Cache'e kaydediliyor (cacheService.saveRecipes())
    //      g) UserRecipeService'e kaydediliyor (Hive'a, duplicate kontrolü ile)
    //      h) Döndürülüyor
    //
    // ❌ Firestore'a kaydediliyor: HAYIR
    // ✅ Hive cache'e kaydediliyor: EVET (cacheService.saveRecipes)
    // ✅ UserRecipeService'e kaydediliyor: EVET (userRecipeRepository.addRecipe)
    //
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

    // Cache boşsa boş liste döndür - OpenAI isteği atma
    // Kullanıcı "Dolaptakilerden Tarif Öner" butonuna bastığında yeni tarifler gelecek
    debugPrint(
      '[RecipesCubit] Cache boş, meal: $meal - boş liste döndürülüyor (isteğe gerek yok)',
    );
    return <Recipe>[];
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
    // ✅ Hive cache'e kaydediliyor: EVET (cacheService.addRecipesToCache)
    // ✅ UserRecipeService'e kaydediliyor: EVET (userRecipeRepository.addRecipe)
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

      // 🔄 YENİ AKIŞ: Firestore-önce, sonra OpenAI mantığı
      // Repository helper'ı kullanarak önce Firestore'dan oku, eksik kalanı OpenAI ile tamamla
      final List<Recipe> recipes = await recipesRepository
          .getRecipesFromFirestoreFirst(
            userId: userId,
            meal: meal,
            ingredients: ingredients,
            prompt: contextPrompt,
            targetCount: 6,
            excludeTitles: allExcludeTitles,
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

      // promptPreferences.incrementGenerated kaldırıldı - repository içinde zaten güncelleniyor

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
