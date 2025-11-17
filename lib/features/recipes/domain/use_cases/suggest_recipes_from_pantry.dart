// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';

class SuggestRecipesFromPantry {
  const SuggestRecipesFromPantry(this.repository);

  final IRecipesRepository repository;

  Future<List<Recipe>> call({required String householdId}) =>
      repository.suggestFromPantry(householdId: householdId);
}
