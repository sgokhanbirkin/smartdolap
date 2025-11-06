// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

abstract class IRecipesRepository {
  Future<List<Recipe>> suggestFromPantry({required String userId});
}
