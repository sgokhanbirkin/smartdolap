import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_cache_service.dart';

/// Service responsible for caching recipes in Hive
/// Follows Single Responsibility Principle - only handles cache operations
class RecipeCacheService implements IRecipeCacheService {
  RecipeCacheService(this._cacheBox);

  final Box<dynamic> _cacheBox;

  /// Get cache key for meal-specific recipes
  String getMealCacheKey(String userId, String meal) =>
      'recipes_cache_${meal}_$userId';

  /// Get recipes from cache as Map list
  List<Map<String, Object?>>? getRecipes(String cacheKey) {
    final List<dynamic>? cachedRecipes =
        _cacheBox.get(cacheKey) as List<dynamic>?;
    if (cachedRecipes == null || cachedRecipes.isEmpty) {
      return null;
    }

    return cachedRecipes.map<Map<String, Object?>>((dynamic item) {
      final Map<dynamic, dynamic> map = item as Map<dynamic, dynamic>;
      return <String, Object?>{
        'id': map['id'] as String?,
        'title': map['title'] as String?,
        'ingredients': map['ingredients'] as List<dynamic>?,
        'steps': map['steps'] as List<dynamic>?,
        'calories': map['calories'] as num?,
        'durationMinutes': map['durationMinutes'] as num?,
        'difficulty': map['difficulty'] as String?,
        'imageUrl': map['imageUrl'] as String?,
        'category': map['category'] as String?,
        'fiber': map['fiber'] as num?,
      };
    }).toList();
  }

  /// Get recipes from cache as Recipe list
  List<Recipe>? getRecipesAsRecipeList(String cacheKey) {
    final List<Map<String, Object?>>? cached = getRecipes(cacheKey);
    if (cached == null || cached.isEmpty) {
      return null;
    }

    return cached.map((Map<String, Object?> map) {
      return Recipe.fromMap(map as Map<dynamic, dynamic>);
    }).toList();
  }

  /// Save recipes to cache (replaces existing) - alias for saveRecipes
  Future<void> putRecipes(String cacheKey, List<Recipe> recipes) async {
    return saveRecipes(cacheKey, recipes);
  }

  /// Save recipes to cache (replaces existing)
  Future<void> saveRecipes(String cacheKey, List<Recipe> recipes) async {
    final List<Map<String, Object?>> cacheData = recipes
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
            'category': e.category,
            'fiber': e.fiber,
          },
        )
        .toList();

    await _cacheBox.put(cacheKey, cacheData);
    debugPrint(
      '[RecipeCacheService] Cache\'e kaydedildi ($cacheKey) - ${recipes.length} tarif',
    );
  }

  /// Add recipes to existing cache (prepends new recipes)
  Future<void> addRecipesToCache(
    String cacheKey,
    List<Recipe> newRecipes,
  ) async {
    final List<Map<String, Object?>>? existingCache = getRecipes(cacheKey);
    final List<Map<String, Object?>> newCacheData = newRecipes
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
            'category': e.category,
            'fiber': e.fiber,
          },
        )
        .toList();

    if (existingCache != null && existingCache.isNotEmpty) {
      // Remove duplicates based on title
      final Set<String> existingTitles = existingCache
          .map((Map<String, Object?> e) => e['title'] as String?)
          .whereType<String>()
          .toSet();

      final List<Map<String, Object?>> uniqueNewRecipes = newCacheData.where((
        Map<String, Object?> e,
      ) {
        final String? title = e['title'] as String?;
        return title != null && !existingTitles.contains(title);
      }).toList();

      final List<Map<String, Object?>> combinedCache = <Map<String, Object?>>[
        ...uniqueNewRecipes, // New recipes on top
        ...existingCache, // Old recipes below
      ];

      await _cacheBox.put(cacheKey, combinedCache);
      debugPrint(
        '[RecipeCacheService] Cache\'e eklendi ($cacheKey) - ${uniqueNewRecipes.length} yeni tarif, toplam: ${combinedCache.length}',
      );
    } else {
      await _cacheBox.put(cacheKey, newCacheData);
      debugPrint(
        '[RecipeCacheService] Cache\'e kaydedildi ($cacheKey) - ${newRecipes.length} yeni tarif',
      );
    }
  }

  /// Delete recipes from cache by titles
  Future<void> deleteRecipesByTitles(
    String cacheKey,
    List<String> titles,
  ) async {
    final List<Map<String, Object?>>? existingCache = getRecipes(cacheKey);
    if (existingCache == null || existingCache.isEmpty) {
      return;
    }

    final Set<String> titlesSet = titles.toSet();
    final List<Map<String, Object?>> remaining = existingCache.where((
      Map<String, Object?> e,
    ) {
      final String? title = e['title'] as String?;
      return title != null && !titlesSet.contains(title);
    }).toList();

    await _cacheBox.put(cacheKey, remaining);
    debugPrint(
      '[RecipeCacheService] Cache\'den silindi ($cacheKey) - ${titles.length} tarif, kalan: ${remaining.length}',
    );
  }
}
