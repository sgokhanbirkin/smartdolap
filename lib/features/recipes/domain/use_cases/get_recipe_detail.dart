// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';

class GetRecipeDetail {
  const GetRecipeDetail(this.repository);

  final IRecipesRepository repository;

  Future<Recipe?> call(String recipeId, {required String userId}) =>
      repository.getRecipeDetail(recipeId, userId: userId);
}
