import 'package:smartdolap/features/household/domain/entities/shared_recipe.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';

/// Shared recipe repository contract
abstract class ISharedRecipeRepository {
  /// Watch shared recipes for a household
  Stream<List<SharedRecipe>> watchSharedRecipes(String householdId);

  /// Share a recipe
  Future<SharedRecipe> shareRecipe({
    required String householdId,
    required String userId,
    required String userName,
    required UserRecipe recipe,
    String? avatarId,
  });

  /// Delete a shared recipe
  Future<void> deleteSharedRecipe({
    required String householdId,
    required String recipeId,
  });
}

