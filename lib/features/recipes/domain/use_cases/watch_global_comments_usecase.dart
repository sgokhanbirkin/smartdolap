import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_comment_repository.dart';

/// Use case for watching global comments for a recipe
class WatchGlobalCommentsUseCase {
  /// Watch global comments use case constructor
  WatchGlobalCommentsUseCase(this._repository);

  final ICommentRepository _repository;

  /// Execute watching global comments
  Stream<List<RecipeComment>> call(String recipeId) {
    return _repository.watchGlobalComments(recipeId);
  }
}
