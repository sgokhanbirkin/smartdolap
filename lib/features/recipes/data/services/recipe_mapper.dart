import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Service responsible for mapping between different data formats and Recipe entity
/// Follows Single Responsibility Principle - only handles data mapping
class RecipeMapper {
  /// Map from `Map<String, Object?>` to `Recipe`.
  static Recipe fromMap(Map<String, Object?> map, {String? defaultCategory}) =>
      // Use Recipe.fromMap which handles both string and RecipeStep lists
      Recipe.fromMap(map as Map<dynamic, dynamic>);

  /// Map from `List<Map<String, Object?>>` to `List<Recipe>`.
  static List<Recipe> fromMapList(
    List<Map<String, Object?>> maps, {
    String? defaultCategory,
  }) => maps
      .map(
        (Map<String, Object?> map) =>
            fromMap(map, defaultCategory: defaultCategory),
      )
      .toList();

  /// Map from `Recipe` to `Map<String, Object?>`.
  static Map<String, Object?> toMap(Recipe recipe) => recipe.toMap();

  /// Map from `List<Recipe>` to `List<Map<String, Object?>>`.
  static List<Map<String, Object?>> toMapList(List<Recipe> recipes) =>
      recipes.map(toMap).toList();
}
