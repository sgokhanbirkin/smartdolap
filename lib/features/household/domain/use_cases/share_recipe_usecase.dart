import 'package:smartdolap/features/household/domain/entities/shared_recipe.dart';
import 'package:smartdolap/features/household/domain/repositories/i_shared_recipe_repository.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';

/// Share recipe use case - Business logic for sharing a recipe
class ShareRecipeUseCase {
  /// Share recipe use case constructor
  const ShareRecipeUseCase(this.repository);

  /// Shared recipe repository
  final ISharedRecipeRepository repository;

  /// Execute sharing recipe
  Future<SharedRecipe> call({
    required String householdId,
    required String userId,
    required String userName,
    required UserRecipe recipe,
    String? avatarId,
  }) =>
      repository.shareRecipe(
        householdId: householdId,
        userId: userId,
        userName: userName,
        recipe: recipe,
        avatarId: avatarId,
      );
}

