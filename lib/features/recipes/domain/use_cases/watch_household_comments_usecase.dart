import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_comment_repository.dart';

/// Use case for watching household comments for a recipe
class WatchHouseholdCommentsUseCase {
  /// Watch household comments use case constructor
  WatchHouseholdCommentsUseCase(this._repository);

  final ICommentRepository _repository;

  /// Execute watching household comments
  Stream<List<RecipeComment>> call(String recipeId, String householdId) {
    return _repository.watchHouseholdComments(recipeId, householdId);
  }
}
