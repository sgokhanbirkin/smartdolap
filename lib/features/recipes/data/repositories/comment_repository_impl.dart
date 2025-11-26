import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_comment_repository.dart';

/// Comment repository implementation using Firestore
class CommentRepositoryImpl implements ICommentRepository {
  /// Comment repository constructor
  CommentRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _recipes = 'recipes';
  static const String _comments = 'comments';
  static const String _households = 'households';
  static const String _recipeComments = 'recipeComments';

  @override
  Stream<List<RecipeComment>> watchGlobalComments(String recipeId) =>
      // Global comments are stored in recipes/{recipeId}/comments
      // Note: recipes/{recipeId} document may not exist initially
      // Firestore will return empty list if document doesn't exist (which is fine)
      _firestore
          .collection(_recipes)
          .doc(recipeId)
          .collection(_comments)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
                .map(
                  (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                      RecipeComment.fromJson(doc.data()),
                )
                .toList(),
          );

  @override
  Stream<List<RecipeComment>> watchHouseholdComments(
    String recipeId,
    String householdId,
  ) => _firestore
        .collection(_households)
        .doc(householdId)
        .collection(_recipeComments)
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    RecipeComment.fromJson(doc.data()),
              )
              .toList(),
        );

  @override
  Future<void> addComment(RecipeComment comment) async {
    if (comment.isHouseholdOnly) {
      // Save to household recipeComments collection
      if (comment.householdId == null) {
        throw ArgumentError(
          'householdId is required when isHouseholdOnly is true',
        );
      }
      await _firestore
          .collection(_households)
          .doc(comment.householdId)
          .collection(_recipeComments)
          .doc(comment.id)
          .set(comment.toJson());
    } else {
      // Save to global recipes/{recipeId}/comments collection
      // Ensure recipe document exists (create if it doesn't)
      final DocumentReference<Map<String, dynamic>> recipeDoc = _firestore
          .collection(_recipes)
          .doc(comment.recipeId);

      // Check if document exists, if not create it
      final DocumentSnapshot<Map<String, dynamic>> recipeSnapshot =
          await recipeDoc.get();
      if (!recipeSnapshot.exists) {
        await recipeDoc.set(<String, dynamic>{
          'id': comment.recipeId,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      // Add comment
      await recipeDoc
          .collection(_comments)
          .doc(comment.id)
          .set(comment.toJson());
    }
  }

  @override
  Future<void> deleteComment({
    required String commentId,
    required String recipeId,
    required bool isHouseholdOnly,
    String? householdId,
  }) async {
    if (isHouseholdOnly) {
      // Delete from household recipeComments collection
      if (householdId == null) {
        throw ArgumentError(
          'householdId is required when isHouseholdOnly is true',
        );
      }
      await _firestore
          .collection(_households)
          .doc(householdId)
          .collection(_recipeComments)
          .doc(commentId)
          .delete();
    } else {
      // Delete from global recipes/{recipeId}/comments collection
      await _firestore
          .collection(_recipes)
          .doc(recipeId)
          .collection(_comments)
          .doc(commentId)
          .delete();
    }
  }
}
