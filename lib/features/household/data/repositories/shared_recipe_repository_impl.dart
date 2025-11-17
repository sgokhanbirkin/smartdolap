import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/household/domain/entities/shared_recipe.dart';
import 'package:smartdolap/features/household/domain/repositories/i_shared_recipe_repository.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:uuid/uuid.dart';

/// Shared recipe repository implementation
class SharedRecipeRepositoryImpl implements ISharedRecipeRepository {
  /// Shared recipe repository constructor
  SharedRecipeRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _households = 'households';
  static const String _sharedRecipes = 'sharedRecipes';
  static const Uuid _uuid = Uuid();

  @override
  Stream<List<SharedRecipe>> watchSharedRecipes(String householdId) {
    return _firestore
        .collection(_households)
        .doc(householdId)
        .collection(_sharedRecipes)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    SharedRecipe.fromJson(doc.data()),
              )
              .toList(),
        );
  }

  @override
  Future<SharedRecipe> shareRecipe({
    required String householdId,
    required String userId,
    required String userName,
    required UserRecipe recipe,
    String? avatarId,
  }) async {
    final String sharedRecipeId = _uuid.v4();
    final DateTime now = DateTime.now();

    final SharedRecipe sharedRecipe = SharedRecipe(
      id: sharedRecipeId,
      householdId: householdId,
      sharedBy: userId,
      sharedByName: userName,
      avatarId: avatarId,
      recipe: recipe,
      createdAt: now,
    );

    await _firestore
        .collection(_households)
        .doc(householdId)
        .collection(_sharedRecipes)
        .doc(sharedRecipeId)
        .set(sharedRecipe.toJson());

    return sharedRecipe;
  }

  @override
  Future<void> deleteSharedRecipe({
    required String householdId,
    required String recipeId,
  }) async {
    await _firestore
        .collection(_households)
        .doc(householdId)
        .collection(_sharedRecipes)
        .doc(recipeId)
        .delete();
  }
}
