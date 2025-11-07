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
  const RecipesLoaded(
    this.recipes, {
    this.isLoadingMore = false,
    this.activeFilters = const <String, dynamic>{},
    this.allRecipes,
  });
  final List<Recipe> recipes;
  final bool isLoadingMore;
  final Map<String, dynamic> activeFilters; // Filter state
  final List<Recipe>? allRecipes; // Original unfiltered list

  int get activeFilterCount {
    int count = 0;
    if (activeFilters['ingredients'] != null &&
        (activeFilters['ingredients'] as List).isNotEmpty) {
      count++;
    }
    if (activeFilters['meal'] != null) count++;
    if (activeFilters['maxCalories'] != null) count++;
    if (activeFilters['minFiber'] != null) count++;
    return count;
  }
}

class RecipesFailure extends RecipesState {
  const RecipesFailure(this.message);
  final String message;
}
