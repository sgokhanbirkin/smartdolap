import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Service responsible for filtering recipes
/// Follows Single Responsibility Principle - only handles recipe filtering logic
class RecipeFilterService {
  /// Filter recipes by excluded titles
  static List<Recipe> filterByExcludedTitles(
    List<Recipe> recipes,
    List<String> excludeTitles,
  ) {
    final Set<String> excluded = excludeTitles.toSet();
    return recipes.where((Recipe r) => !excluded.contains(r.title)).toList();
  }

  /// Filter recipes by ingredients (at least one ingredient must match)
  static List<Recipe> filterByIngredients(
    List<Recipe> recipes,
    List<Ingredient> ingredients,
  ) {
    if (ingredients.isEmpty) {
      return recipes;
    }

    final List<String> ingredientNames =
        ingredients.map((Ingredient e) => e.name.toLowerCase()).toList();

    return recipes.where((Recipe r) {
      final List<String> recipeIngs =
          r.ingredients.map((String e) => e.toLowerCase()).toList();
      return ingredientNames.any((String ing) => recipeIngs.contains(ing));
    }).toList();
  }

  /// Apply all filters (excluded titles + ingredients)
  static List<Recipe> applyFilters(
    List<Recipe> recipes,
    List<String> excludeTitles,
    List<Ingredient> ingredients,
  ) {
    List<Recipe> filtered = filterByExcludedTitles(recipes, excludeTitles);
    filtered = filterByIngredients(filtered, ingredients);
    return filtered;
  }

  /// Take first N recipes
  static List<Recipe> takeFirst(List<Recipe> recipes, int count) {
    return recipes.take(count).toList();
  }
}

