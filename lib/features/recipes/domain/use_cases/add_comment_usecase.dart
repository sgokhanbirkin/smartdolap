import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_comment_repository.dart';

/// Use case for adding a comment to a recipe
class AddCommentUseCase {
  /// Add comment use case constructor
  AddCommentUseCase(this._repository);

  final ICommentRepository _repository;

  /// Execute adding a comment
  Future<void> call(RecipeComment comment) async {
    await _repository.addComment(comment);
  }
}
