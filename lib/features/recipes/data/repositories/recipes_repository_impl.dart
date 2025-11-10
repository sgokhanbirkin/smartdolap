// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/recipes/data/services/firestore_recipe_mapper.dart';
import 'package:smartdolap/features/recipes/data/services/firestore_recipe_query_builder.dart';
import 'package:smartdolap/features/recipes/data/services/missing_ingredient_calculator.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_filter_service.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_cache_service.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_image_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/product/services/openai/openai_parsing_exception.dart';

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
  );

  final FirebaseFirestore _firestore;
  final IPantryRepository _pantry;
  final IOpenAIService _openai;
  final PromptPreferenceService _promptPrefs;
  final RecipeImageService _recipeImageService;
  final RecipeCacheService _recipeCacheService;

  // ============================================================================
  // PRIVATE HELPER: OpenAI + Firestore yazma işlemini tek bir yerde topla
  // Follows Single Responsibility Principle - delegates to specialized services
  // ============================================================================
  /// Generates recipes using OpenAI and saves them to Firestore
  /// Returns the generated Recipe list with Firestore document IDs
  Future<List<Recipe>> _generateRecipesWithOpenAIAndSave({
    required String userId,
    required List<Ingredient> ingredients,
    required String prompt,
    required int count,
    String? meal,
    List<String> excludeTitles = const <String>[],
  }) async {
    print(
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

    print(
      '[RecipesRepository] OpenAI yanıtı geldi - ${suggestions.length} öneri',
    );

      // Her tarif için görsel düzelt ve Firestore'a kaydet
      final List<Recipe> recipes = <Recipe>[];
      for (final RecipeSuggestion s in suggestions) {
        // Kullanıcıya özel recipes subcollection kullan
        final DocumentReference<Map<String, dynamic>> doc = _firestore
            .collection('users')
            .doc(userId)
            .collection('recipes')
            .doc();

      // MissingCount hesapla - MissingIngredientCalculator servisi kullan
      final int missing = MissingIngredientCalculator.calculateMissingCount(
        s.ingredients,
        ingredients,
      );

      // Görsel düzelt - RecipeImageService kullan
      final String? imageUrl = await _recipeImageService.fixImageUrl(
        s.imageUrl,
        s.title,
      );

      // Recipe objesi oluştur
      final Recipe recipe = Recipe(
        id: doc.id,
        title: s.title,
        ingredients: s.ingredients,
        steps: s.steps,
        calories: s.calories,
        durationMinutes: s.durationMinutes,
        difficulty: s.difficulty,
        imageUrl: imageUrl,
        category: s.category ?? meal,
        missingCount: missing,
        fiber: s.fiber,
      );

      // Firestore'a kaydet - FirestoreRecipeMapper kullan
      await doc.set(FirestoreRecipeMapper.toMap(recipe));

      recipes.add(recipe);
    }

    // PromptPreferences güncelle
    await _promptPrefs.incrementGenerated(recipes.length);

    print(
      '[RecipesRepository] _generateRecipesWithOpenAIAndSave tamamlandı - '
      '${recipes.length} tarif Firestore\'a kaydedildi',
    );

    return recipes;
  }

  // ============================================================================
  // PUBLIC HELPER: Firestore-önce, sonra OpenAI mantığı
  // ============================================================================
  /// Gets recipes from Firestore first, then generates remaining with OpenAI
  /// Returns combined list of Firestore recipes + newly generated recipes
  /// Priority: Hive Cache → Firestore → OpenAI
  Future<List<Recipe>> getRecipesFromFirestoreFirst({
    required String userId,
    String? meal,
    required List<Ingredient> ingredients,
    required String prompt,
    required int targetCount,
    List<String> excludeTitles = const <String>[],
  }) async {
    print(
      '[RecipesRepository] getRecipesFromFirestoreFirst başladı - '
      'userId: $userId, meal: $meal, targetCount: $targetCount',
    );

    // 1. ÖNCE HIVE CACHE'DEN KONTROL ET
    final String cacheKey = _recipeCacheService.getMealCacheKey(
      userId,
      meal ?? 'general',
    );
    final List<Recipe>? cachedRecipes = _recipeCacheService.getRecipesAsRecipeList(
      cacheKey,
    );

    if (cachedRecipes != null && cachedRecipes.isNotEmpty) {
      print(
        '[RecipesRepository] Hive cache\'den ${cachedRecipes.length} tarif bulundu',
      );
      
      // Cache'deki tarifleri filtrele
      List<Recipe> filteredCached = RecipeFilterService.filterRecipes(
        cachedRecipes,
        excludeTitles,
        ingredients,
      );
      
      filteredCached = RecipeFilterService.takeFirst(
        filteredCached,
        targetCount,
      );

      if (filteredCached.length >= targetCount) {
        print(
          '[RecipesRepository] Hive cache yeterli, ${filteredCached.length} tarif döndürülüyor',
        );
        // Arka planda Firestore'dan güncelle
        _syncFromFirestoreInBackground(
          userId: userId,
          meal: meal,
          ingredients: ingredients,
          prompt: prompt,
          targetCount: targetCount,
          excludeTitles: excludeTitles,
        );
        return filteredCached;
      }

      // Cache yetersizse Firestore'dan devam et
      print(
        '[RecipesRepository] Hive cache yetersiz (${filteredCached.length}/$targetCount), '
        'Firestore\'dan devam ediliyor',
      );
    }

    // 2. HIVE BOŞ VEYA YETERSİZSE FIRESTORE'DAN ÇEK
    try {
      // Kullanıcıya özel recipes subcollection kullan
      final CollectionReference<Map<String, dynamic>> collection =
          _firestore.collection('users').doc(userId).collection('recipes');
      final Query<Map<String, dynamic>> query =
          FirestoreRecipeQueryBuilder.buildQuery(
        collection: collection,
        meal: meal,
        limit: targetCount * 2,
      );

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      final List<Recipe> allRecipes =
          FirestoreRecipeMapper.fromQuerySnapshot(snapshot);

      print(
        '[RecipesRepository] Firestore\'dan ${allRecipes.length} tarif bulundu',
      );

      List<Recipe> firestoreRecipes = RecipeFilterService.filterRecipes(
        allRecipes,
        excludeTitles,
        ingredients,
      );

      firestoreRecipes = RecipeFilterService.takeFirst(
        firestoreRecipes,
        targetCount,
      );

      print(
        '[RecipesRepository] Filtreleme sonrası ${firestoreRecipes.length} tarif',
      );

      // Firestore'dan gelen tarifleri cache'e kaydet
      if (firestoreRecipes.isNotEmpty) {
        await _recipeCacheService.putRecipes(cacheKey, firestoreRecipes);
      }

      // Eğer Firestore yeterliyse direkt dön
      if (firestoreRecipes.length >= targetCount) {
        print(
          '[RecipesRepository] Firestore yeterli, ${firestoreRecipes.length} tarif döndürülüyor',
        );
        return firestoreRecipes;
      }

      // 3. EKSİK KALANI OPENAI İLE TAMAMLA
      final int remaining = targetCount - firestoreRecipes.length;
      print(
        '[RecipesRepository] Firestore yetersiz, $remaining tarif OpenAI ile tamamlanacak',
      );

      if (remaining > 0) {
        try {
          final List<Recipe> generated = await _generateRecipesWithOpenAIAndSave(
            userId: userId,
            ingredients: ingredients,
            prompt: prompt,
            count: remaining,
            meal: meal,
            excludeTitles: <String>[
              ...excludeTitles,
              ...firestoreRecipes.map((Recipe r) => r.title),
            ],
          );

          final List<Recipe> combined = <Recipe>[...firestoreRecipes, ...generated];
          
          // Yeni tarifleri cache'e ekle
          await _recipeCacheService.addRecipesToCache(cacheKey, generated);
          
          print(
            '[RecipesRepository] getRecipesFromFirestoreFirst tamamlandı - '
            'Toplam ${combined.length} tarif (${firestoreRecipes.length} Firestore, '
            '${generated.length} OpenAI)',
          );
          return combined;
        } on OpenAIParsingException catch (e) {
          Logger.error(
            '[RecipesRepository] OpenAI parsing error in getRecipesFromFirestoreFirst',
            e,
          );
          if (firestoreRecipes.isNotEmpty) {
            print(
              '[RecipesRepository] OpenAI hatası, Firestore\'dan ${firestoreRecipes.length} tarif döndürülüyor',
            );
            return firestoreRecipes;
          }
          rethrow;
        } catch (e) {
          Logger.error(
            '[RecipesRepository] OpenAI error in getRecipesFromFirestoreFirst',
            e,
          );
          if (firestoreRecipes.isNotEmpty) {
            print(
              '[RecipesRepository] OpenAI hatası, Firestore\'dan ${firestoreRecipes.length} tarif döndürülüyor',
            );
            return firestoreRecipes;
          }
          rethrow;
        }
      }

      return firestoreRecipes;
    } on Exception catch (e) {
      Logger.error(
        '[RecipesRepository] Firestore error in getRecipesFromFirestoreFirst',
        e,
      );
      print(
        '[RecipesRepository] Firestore hatası: $e, OpenAI\'ye fallback yapılıyor',
      );
      return _generateRecipesWithOpenAIAndSave(
        userId: userId,
        ingredients: ingredients,
        prompt: prompt,
        count: targetCount,
        meal: meal,
        excludeTitles: excludeTitles,
      );
    }
  }

  /// Syncs from Firestore in background without blocking
  void _syncFromFirestoreInBackground({
    required String userId,
    String? meal,
    required List<Ingredient> ingredients,
    required String prompt,
    required int targetCount,
    List<String> excludeTitles = const <String>[],
  }) {
    // Arka planda Firestore'dan güncelle, cache'i güncelle
    Future<void>.delayed(const Duration(milliseconds: 500), () async {
      try {
        // Kullanıcıya özel recipes subcollection kullan
        final CollectionReference<Map<String, dynamic>> collection =
            _firestore.collection('users').doc(userId).collection('recipes');
        final Query<Map<String, dynamic>> query =
            FirestoreRecipeQueryBuilder.buildQuery(
          collection: collection,
          meal: meal,
          limit: targetCount * 2,
        );

        final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
        final List<Recipe> allRecipes =
            FirestoreRecipeMapper.fromQuerySnapshot(snapshot);

        List<Recipe> firestoreRecipes = RecipeFilterService.filterRecipes(
          allRecipes,
          excludeTitles,
          ingredients,
        );

        firestoreRecipes = RecipeFilterService.takeFirst(
          firestoreRecipes,
          targetCount,
        );

        if (firestoreRecipes.isNotEmpty) {
          final String cacheKey = _recipeCacheService.getMealCacheKey(
            userId,
            meal ?? 'general',
          );
          await _recipeCacheService.putRecipes(cacheKey, firestoreRecipes);
          print(
            '[RecipesRepository] Arka planda cache güncellendi - ${firestoreRecipes.length} tarif',
          );
        }
      } catch (e) {
        // Silently fail - cache is already available
        print('[RecipesRepository] Arka plan sync hatası: $e');
      }
    });
  }

  @override
  Future<List<Recipe>> suggestFromPantry({required String userId}) async {
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
    //      a) Firestore'da yeni document oluşturuluyor (_firestore.collection('recipes').doc())
    //      b) Görsel düzeltiliyor (ImageLookupService ile, eğer OpenAI'den gelen görsel geçersizse)
    //      c) missingCount hesaplanıyor (pantry'de olmayan malzemeler)
    //      d) Firestore'a kaydediliyor (doc.set())
    //      e) Recipe objesi oluşturuluyor (Firestore doc.id ile)
    //   6. PromptPreferences güncelleniyor (incrementGenerated)
    //   7. Recipe listesi döndürülüyor
    //
    // ✅ Firestore'a kaydediliyor: EVET (her tarif için ayrı document)
    // ❌ Hive cache'e kaydediliyor: HAYIR (sadece Firestore'a kaydediliyor)
    // ❌ UserRecipeService'e kaydediliyor: HAYIR
    //
    // ⚠️ NOT: Bu metod diğer metodlardan (loadMeal, loadMoreMealRecipes, loadWithSelection)
    //    farklı olarak Firestore'a kaydediyor. Bu tutarsızlık var!
    // ============================================================================
    print('[RecipesRepository] suggestFromPantry başladı - userId: $userId');
    final DateTime repoStartTime = DateTime.now();
    
    print('[RecipesRepository] Pantry items yükleniyor...');
    final List<dynamic> pantryItemsRaw = await _pantry.getItems(userId: userId);
    final List<PantryItem> pantryItems = pantryItemsRaw.cast<PantryItem>();
    print('[RecipesRepository] ${pantryItems.length} pantry item bulundu');
    
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
      userId: userId,
      ingredients: ingredients,
      prompt: contextPrompt,
      count: 6, // Default count (OpenAI'den kaç tarif isteniyor)
      excludeTitles: const <String>[],
    );

    final Duration repoDuration = DateTime.now().difference(repoStartTime);
    print('[RecipesRepository] suggestFromPantry tamamlandı - ${recipes.length} tarif, Toplam süre: ${repoDuration.inSeconds} saniye');
    return recipes;
  }

  @override
  Future<Recipe?> getRecipeDetail(String recipeId, {required String userId}) async {
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
