import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';

/// Comment repository contract
/// Follows Dependency Inversion Principle
abstract class ICommentRepository {
  /// Watch global comments for a recipe (visible to everyone)
  /// Streams comments from recipes/{recipeId}/comments collection
  Stream<List<RecipeComment>> watchGlobalComments(String recipeId);

  /// Watch household comments for a recipe (visible only to household members)
  /// Streams comments from households/{householdId}/recipeComments collection
  /// filtered by recipeId
  Stream<List<RecipeComment>> watchHouseholdComments(
    String recipeId,
    String householdId,
  );

  /// Add a comment
  /// If isHouseholdOnly is true, saves to households/{householdId}/recipeComments
  /// Otherwise, saves to recipes/{recipeId}/comments
  Future<void> addComment(RecipeComment comment);

  /// Delete a comment
  /// Requires recipeId, isHouseholdOnly, and optional householdId
  Future<void> deleteComment({
    required String commentId,
    required String recipeId,
    required bool isHouseholdOnly,
    String? householdId,
  });
}

