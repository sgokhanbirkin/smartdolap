import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Interface for caching recipes
/// Follows Dependency Inversion Principle (DIP)
abstract class IRecipeCacheService {
  /// Get cache key for meal-specific recipes
  String getMealCacheKey(String userId, String meal);

  /// Get recipes from cache as Map list
  List<Map<String, Object?>>? getRecipes(String cacheKey);

  /// Get recipes from cache as Recipe list
  List<Recipe>? getRecipesAsRecipeList(String cacheKey);

  /// Save recipes to cache (replaces existing) - alias for saveRecipes
  Future<void> putRecipes(String cacheKey, List<Recipe> recipes);

  /// Save recipes to cache (replaces existing)
  Future<void> saveRecipes(String cacheKey, List<Recipe> recipes);

  /// Add recipes to existing cache (prepends new recipes)
  Future<void> addRecipesToCache(String cacheKey, List<Recipe> newRecipes);

  /// Delete recipes from cache by titles
  Future<void> deleteRecipesByTitles(String cacheKey, List<String> titles);
}
