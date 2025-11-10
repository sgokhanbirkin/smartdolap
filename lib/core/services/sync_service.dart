import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/recipes/data/services/firestore_recipe_mapper.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_cache_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';

/// Service for syncing Firestore data to Hive cache
/// Follows Single Responsibility Principle - only handles sync logic
class SyncService {
  /// Creates a sync service
  SyncService({
    required this.firestore,
    required this.pantryRepository,
    required this.recipesRepository,
    required this.pantryBox,
    required this.recipeCacheService,
  });

  final FirebaseFirestore firestore;
  final IPantryRepository pantryRepository;
  final IRecipesRepository recipesRepository;
  final Box<dynamic> pantryBox;
  final RecipeCacheService recipeCacheService;

  /// Syncs all user data from Firestore to Hive
  /// Called after login/register to ensure local cache is up-to-date
  Future<void> syncUserData({required String userId}) async {
    try {
      Logger.info('[SyncService] Starting sync for user: $userId');

      // Sync pantry items
      await _syncPantryItems(userId);

      // Sync recipes (user-specific recipes from Firestore)
      await _syncRecipes(userId);

      Logger.info('[SyncService] Sync completed for user: $userId');
    } catch (e, s) {
      Logger.error('[SyncService] Sync error for user: $userId', e, s);
      // Don't rethrow - sync should be resilient and not block login
    }
  }

  /// Syncs pantry items from Firestore to Hive
  Future<void> _syncPantryItems(String userId) async {
    try {
      Logger.info('[SyncService] Syncing pantry items for user: $userId');

      // Get items from Firestore (this already writes to cache)
      await pantryRepository.getItems(userId: userId);

      Logger.info('[SyncService] Pantry items synced to Hive');
    } catch (e, s) {
      Logger.error('[SyncService] Error syncing pantry items', e, s);
      // Don't rethrow - sync should be resilient
    }
  }

  /// Syncs recipes from Firestore to Hive
  /// Only syncs recipes that belong to the user or are public
  Future<void> _syncRecipes(String userId) async {
    try {
      Logger.info('[SyncService] Syncing recipes for user: $userId');

      // Get recipes from Firestore (public recipes)
      // Note: User-specific recipes are handled separately
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('recipes')
          .limit(100) // Limit to prevent too much data
          .get();

      final List<Recipe> recipes = FirestoreRecipeMapper.fromQuerySnapshot(
        snapshot,
      );

      // Group recipes by meal and sync to cache
      final Map<String, List<Recipe>> recipesByMeal = <String, List<Recipe>>{};
      for (final Recipe recipe in recipes) {
        final String meal = recipe.category ?? 'general';
        recipesByMeal.putIfAbsent(meal, () => <Recipe>[]).add(recipe);
      }

      // Sync each meal's recipes to cache
      for (final MapEntry<String, List<Recipe>> entry
          in recipesByMeal.entries) {
        final String cacheKey = recipeCacheService.getMealCacheKey(
          userId,
          entry.key,
        );
        await recipeCacheService.putRecipes(cacheKey, entry.value);
      }

      Logger.info(
        '[SyncService] Synced ${recipes.length} recipes to Hive (${recipesByMeal.length} meals)',
      );
    } catch (e, s) {
      Logger.error('[SyncService] Error syncing recipes', e, s);
      // Don't rethrow - sync should be resilient
    }
  }
}
