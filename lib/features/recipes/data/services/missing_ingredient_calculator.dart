import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';

/// Service responsible for calculating missing ingredient count
/// Follows Single Responsibility Principle - only handles missing count calculation
class MissingIngredientCalculator {
  /// Calculate how many ingredients from recipe are missing in pantry
  /// Returns the count of ingredients that are not in the provided ingredient list
  static int calculateMissingCount(
    List<String> recipeIngredients,
    List<Ingredient> pantryIngredients,
  ) {
    final Set<String> pantryNames = pantryIngredients
        .map((Ingredient e) => e.name.toLowerCase())
        .toSet();

    return recipeIngredients
        .where((String name) => !pantryNames.contains(name.toLowerCase()))
        .length;
  }
}

