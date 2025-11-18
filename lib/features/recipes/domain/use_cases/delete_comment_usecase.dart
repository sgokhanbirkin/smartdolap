import 'package:smartdolap/features/recipes/domain/repositories/i_comment_repository.dart';

/// Use case for deleting a comment
class DeleteCommentUseCase {
  /// Delete comment use case constructor
  DeleteCommentUseCase(this._repository);

  final ICommentRepository _repository;

  /// Execute deleting a comment
  Future<void> call({
    required String commentId,
    required String recipeId,
    required bool isHouseholdOnly,
    String? householdId,
  }) async {
    await _repository.deleteComment(
      commentId: commentId,
      recipeId: recipeId,
      isHouseholdOnly: isHouseholdOnly,
      householdId: householdId,
    );
  }
}
