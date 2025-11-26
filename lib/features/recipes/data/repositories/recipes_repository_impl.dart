// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_prompt_preference_service.dart';
import 'package:smartdolap/features/recipes/data/services/firestore_recipe_mapper.dart';
import 'package:smartdolap/features/recipes/data/services/missing_ingredient_calculator.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_filter_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_step.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_cache_service.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_image_service.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/features/sync/domain/entities/sync_task.dart';
import 'package:smartdolap/features/sync/domain/services/i_sync_queue_service.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/product/services/openai/openai_parsing_exception.dart';
import 'package:uuid/uuid.dart';

/// Repository implementation for recipes
/// Follows SOLID principles:
/// - Single Responsibility: Only handles recipe data operations
/// - Dependency Inversion: Depends on abstractions (IRecipesRepository)
/// - Open/Closed: Open for extension via new methods, closed for modification
class RecipesRepositoryImpl implements IRecipesRepository {
  RecipesRepositoryImpl(
    this._firestore,
    this._pantry,
    this._openai,
    this._promptPrefs,
    this._recipeImageService,
    this._recipeCacheService,
    this._syncQueue,
  );

  final FirebaseFirestore _firestore;
  final IPantryRepository _pantry;
  final IOpenAIService _openai;
  final IPromptPreferenceService _promptPrefs;
  final IRecipeImageService _recipeImageService;
  final IRecipeCacheService _recipeCacheService;
  final ISyncQueueService _syncQueue;

  // ============================================================================
  // PRIVATE HELPER: OpenAI + Firestore yazma işlemini tek bir yerde topla
  // Follows Single Responsibility Principle - delegates to specialized services
  // ============================================================================
  /// Generates recipes using OpenAI and enqueues sync tasks for Firestore.
  /// Returns the generated Recipe list with locally assigned IDs.
  Future<List<Recipe>> _generateRecipesWithOpenAIAndSave({
    required String userId,
    required List<Ingredient> ingredients,
    required String prompt,
    required int count,
    String? meal,
    List<String> excludeTitles = const <String>[],
  }) async {
    debugPrint(
      '[RecipesRepository] _generateRecipesWithOpenAIAndSave başladı - '
      'count: $count, meal: $meal, excludeTitles: ${excludeTitles.length}',
    );

    final PromptPreferences prefs = _promptPrefs.getPreferences();

    // OpenAI'ye istek at
    final List<RecipeSuggestion> suggestions = await _openai.suggestRecipes(
      ingredients,
      servings: prefs.servings,
      count: count,
      query: prompt,
      excludeTitles: excludeTitles,
    );

    debugPrint(
      '[RecipesRepository] OpenAI yanıtı geldi - ${suggestions.length} öneri',
    );

    // Her tarif için görsel düzelt ve local cache + sync queue'ya kaydet
    final List<Recipe> recipes = <Recipe>[];
    for (final RecipeSuggestion s in suggestions) {
      // MissingCount hesapla - MissingIngredientCalculator servisi kullan
      final int missing = MissingIngredientCalculator.calculateMissingCount(
        s.ingredients,
        ingredients,
      );

      final String recipeId = const Uuid().v4();

      // Görsel düzelt - RecipeImageService kullan
      // ✅ AI'den gelen imageSearchQuery'yi kullan (Pexels/Unsplash için optimize edilmiş)
      final String? imageUrl = await _recipeImageService.fixImageUrl(
        s.imageUrl,
        s.title,
        imageSearchQuery: s.imageSearchQuery,
      );

      // Recipe objesi oluştur
      // Convert String steps to RecipeStep list
      final List<RecipeStep> recipeSteps = s.steps
          .map(RecipeStep.fromString)
          .toList();

      final Recipe recipe = Recipe(
        id: recipeId,
        title: s.title,
        ingredients: s.ingredients,
        steps: recipeSteps,
        calories: s.calories,
        durationMinutes: s.durationMinutes,
        difficulty: s.difficulty,
        imageUrl: imageUrl,
        category: s.category ?? meal,
        missingCount: missing,
        fiber: s.fiber,
      );

      recipes.add(recipe);

      await _syncQueue.enqueue(
        SyncTask(
          entityType: 'recipe',
          operation: 'create',
          payload: FirestoreRecipeMapper.toMap(recipe),
          createdAt: DateTime.now(),
        ),
      );
    }

    // PromptPreferences güncelle
    await _promptPrefs.incrementGenerated(recipes.length);

    debugPrint(
      '[RecipesRepository] _generateRecipesWithOpenAIAndSave tamamlandı - '
      "${recipes.length} tarif Firestore'a kaydedildi",
    );

    return recipes;
  }

  // ============================================================================
  // PUBLIC HELPER: Firestore-önce, sonra OpenAI mantığı
  // ============================================================================
  /// Gets recipes from Firestore first, then generates remaining with OpenAI
  /// Returns combined list of Firestore recipes + newly generated recipes
  /// Priority: Hive Cache → Firestore → OpenAI
  @override
  Future<List<Recipe>> getRecipesFromFirestoreFirst({
    required String userId,
    required List<Ingredient> ingredients,
    required String prompt,
    required int targetCount,
    String? meal,
    List<String> excludeTitles = const <String>[],
  }) async {
    debugPrint(
      '[RecipesRepository] getRecipesFromFirestoreFirst başladı - '
      'userId: $userId, meal: $meal, targetCount: $targetCount',
    );

    // 1. ÖNCE HIVE CACHE'DEN KONTROL ET
    final String cacheKey = _recipeCacheService.getMealCacheKey(
      userId,
      meal ?? 'general',
    );
    final List<Recipe>? cachedRecipes = _recipeCacheService
        .getRecipesAsRecipeList(cacheKey);

    // Cache'deki tarifleri filtrele (boş liste olabilir)
    List<Recipe> filteredCached = <Recipe>[];
    if (cachedRecipes != null && cachedRecipes.isNotEmpty) {
      debugPrint(
        "[RecipesRepository] Hive cache'den ${cachedRecipes.length} tarif bulundu",
      );

      filteredCached = RecipeFilterService.filterRecipes(
        cachedRecipes,
        excludeTitles,
        ingredients,
      );

      filteredCached = RecipeFilterService.takeFirst(
        filteredCached,
        targetCount,
      );

      if (filteredCached.length >= targetCount) {
        debugPrint(
          '[RecipesRepository] ✅ Hive cache yeterli, ${filteredCached.length} tarif döndürülüyor. '
          "Firestore'a istek atılmıyor (Firebase limit optimizasyonu)",
        );
        // Firestore'a gitme - cache yeterli, gereksiz Firebase isteği yapma
        return filteredCached;
      }

      // Cache yetersizse AI'ye devam et
      debugPrint(
        '[RecipesRepository] Hive cache yetersiz (${filteredCached.length}/$targetCount), '
        "AI'ye soruluyor (Firebase limit optimizasyonu)",
      );
    } else {
      debugPrint(
        "[RecipesRepository] Hive cache boş, AI'ye soruluyor (Firebase limit optimizasyonu)",
      );
    }

    // 2. HIVE BOŞ VEYA YETERSİZSE - DİREKT AI'YE SOR (Firestore'a gitme - Firebase limit optimizasyonu)
    debugPrint(
      "[RecipesRepository] ⚡ Firestore'a gitmeden direkt AI'ye soruluyor (Firebase limit optimizasyonu)",
    );

    try {
      // Cache'deki mevcut tarifleri de exclude listesine ekle
      final List<String> allExcludeTitles = <String>[
        ...excludeTitles,
        if (filteredCached.isNotEmpty)
          ...filteredCached.map((Recipe r) => r.title),
      ];

      // Eksik kalan tarif sayısını hesapla
      final int remaining = targetCount - filteredCached.length;
      debugPrint("[RecipesRepository] AI'den $remaining yeni tarif isteniyor");

      if (remaining > 0) {
        final List<Recipe> generated = await _generateRecipesWithOpenAIAndSave(
          userId: userId,
          ingredients: ingredients,
          prompt: prompt,
          count: remaining,
          meal: meal,
          excludeTitles: allExcludeTitles,
        );

        // Yeni tarifleri hem Hive'a hem Firestore'a kaydet (zaten _generateRecipesWithOpenAIAndSave içinde Firestore'a kaydediliyor)
        // Sadece Hive cache'e ekle
        await _recipeCacheService.addRecipesToCache(cacheKey, generated);

        final List<Recipe> combined = <Recipe>[...filteredCached, ...generated];

        debugPrint(
          '[RecipesRepository] ✅ getRecipesFromFirestoreFirst tamamlandı - '
          'Toplam ${combined.length} tarif (${filteredCached.length} Hive cache, '
          '${generated.length} yeni AI tarifi). '
          "Firestore'a sadece yeni tarifler kaydedildi.",
        );
        return combined;
      }

      // Eğer cache yeterliyse (buraya gelmemeli ama güvenlik için)
      return filteredCached;
    } on OpenAIParsingException catch (e) {
      Logger.error(
        '[RecipesRepository] OpenAI parsing error in getRecipesFromFirestoreFirst',
        e,
      );
      if (filteredCached.isNotEmpty) {
        debugPrint(
          "[RecipesRepository] OpenAI hatası, Hive cache'den ${filteredCached.length} tarif döndürülüyor",
        );
        return filteredCached;
      }
      rethrow;
    } catch (e) {
      Logger.error(
        '[RecipesRepository] OpenAI error in getRecipesFromFirestoreFirst',
        e,
      );
      if (filteredCached.isNotEmpty) {
        debugPrint(
          "[RecipesRepository] OpenAI hatası, Hive cache'den ${filteredCached.length} tarif döndürülüyor",
        );
        return filteredCached;
      }
      rethrow;
    }
  }

  @override
  Future<List<Recipe>> suggestFromPantry({required String householdId}) async {
    // ============================================================================
    // 🔄 AKIŞ 1: RecipesRepositoryImpl.suggestFromPantry() - load() metodundan çağrılıyor
    // ============================================================================
    // Bu metod SADECE load() metodu tarafından kullanılıyor ve Firestore'a kaydediyor!
    //
    // ADIMLAR:
    //   1. Pantry items yükleniyor (_pantry.getItems())
    //   2. Ingredient listesine dönüştürülüyor
    //   3. Prompt oluşturuluyor (PromptPreferences ile)
    //   4. OpenAI'ye istek atılıyor (_openai.suggestRecipes())
    //   5. Her tarif için:
    //      a) Görsel düzeltiliyor (ImageLookupService ile, eğer OpenAI'den gelen görsel geçersizse)
    //      b) missingCount hesaplanıyor (pantry'de olmayan malzemeler)
    //      c) Recipe objesi oluşturuluyor (lokal UUID ile)
    //      d) Sync kuyruğuna "create" task'ı ekleniyor (Firestore'a arka planda yazılacak)
    //   6. PromptPreferences güncelleniyor (incrementGenerated)
    //   7. Recipe listesi döndürülüyor
    //
    // ✅ Hive cache'e kaydediliyor: yüklenilen yerde `addRecipesToCache` ile
    // ✅ Firestore'a kaydetme isteği: arka planda sync kuyruğu ile
    // ============================================================================
    debugPrint(
      '[RecipesRepository] suggestFromPantry başladı - householdId: $householdId',
    );
    final DateTime repoStartTime = DateTime.now();

    debugPrint('[RecipesRepository] Pantry items yükleniyor...');
    final List<dynamic> pantryItemsRaw = await _pantry.getItems(
      householdId: householdId,
    );
    final List<PantryItem> pantryItems = pantryItemsRaw.cast<PantryItem>();
    debugPrint('[RecipesRepository] ${pantryItems.length} pantry item bulundu');

    final List<Ingredient> ingredients = pantryItems
        .map<Ingredient>(
          (PantryItem i) =>
              Ingredient(name: i.name, unit: i.unit, quantity: i.quantity),
        )
        .toList();

    final PromptPreferences prefs = _promptPrefs.getPreferences();
    final String contextPrompt = prefs.composePrompt(
      tr(
        'pantry_ingredients_prompt',
        namedArgs: <String, String>{
          'ingredients': ingredients.map((Ingredient e) => e.name).join(', '),
        },
      ),
    );

    // OpenAI çağrısını ve Firestore'a yazma işini private helper'a delega et
    // Davranış değişmedi, sadece kod tekrarı azaltıldı
    final List<Recipe> recipes = await _generateRecipesWithOpenAIAndSave(
      userId:
          householdId, // householdId is used as userId for recipe generation
      ingredients: ingredients,
      prompt: contextPrompt,
      count: 6, // Default count (OpenAI'den kaç tarif isteniyor)
    );

    final Duration repoDuration = DateTime.now().difference(repoStartTime);
    debugPrint(
      '[RecipesRepository] suggestFromPantry tamamlandı - ${recipes.length} tarif, Toplam süre: ${repoDuration.inSeconds} saniye',
    );
    return recipes;
  }

  @override
  Future<Recipe?> getRecipeDetail(
    String recipeId, {
    required String userId,
  }) async {
    try {
      // Kullanıcıya özel recipes subcollection kullan
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(recipeId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      // FirestoreRecipeMapper servisi kullan - SRP
      return FirestoreRecipeMapper.fromDocumentSnapshot(doc);
    } on Exception {
      return null;
    }
  }
}
