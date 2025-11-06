// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

abstract class RecipesState {
  const RecipesState();
}

class RecipesInitial extends RecipesState {
  const RecipesInitial();
}

class RecipesLoading extends RecipesState {
  const RecipesLoading();
}

class RecipesLoaded extends RecipesState {
  const RecipesLoaded(this.recipes);
  final List<Recipe> recipes;
}

class RecipesFailure extends RecipesState {
  const RecipesFailure(this.message);
  final String message;
}
