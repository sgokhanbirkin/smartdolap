// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

abstract class IRecipesRepository {
  Future<List<Recipe>> suggestFromPantry({required String userId});
  Future<Recipe?> getRecipeDetail(String recipeId, {required String userId});

  /// Gets recipes from Firestore first, then generates remaining with OpenAI
  /// Returns combined list of Firestore recipes + newly generated recipes
  Future<List<Recipe>> getRecipesFromFirestoreFirst({
    required String userId,
    String? meal,
    required List<Ingredient> ingredients,
    required String prompt,
    required int targetCount,
    List<String> excludeTitles = const <String>[],
  });
}
