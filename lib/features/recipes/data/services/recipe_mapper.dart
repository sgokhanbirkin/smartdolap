import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Service responsible for mapping between different data formats and Recipe entity
/// Follows Single Responsibility Principle - only handles data mapping
class RecipeMapper {
  /// Map from Map<String, Object?> to Recipe
  static Recipe fromMap(Map<String, Object?> map, {String? defaultCategory}) {
    return Recipe(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      ingredients:
          (map['ingredients'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      steps: (map['steps'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      calories: (map['calories'] as num?)?.toInt(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt(),
      difficulty: (map['difficulty'] as String?) ?? '',
      imageUrl: (map['imageUrl'] as String?) ?? '',
      category: (map['category'] as String?) ?? defaultCategory,
      fiber: (map['fiber'] as num?)?.toInt(),
    );
  }

  /// Map from List<Map<String, Object?>> to List<Recipe>
  static List<Recipe> fromMapList(
    List<Map<String, Object?>> maps, {
    String? defaultCategory,
  }) {
    return maps.map((Map<String, Object?> map) {
      return fromMap(map, defaultCategory: defaultCategory);
    }).toList();
  }

  /// Map from Recipe to Map<String, Object?>
  static Map<String, Object?> toMap(Recipe recipe) {
    return <String, Object?>{
      'id': recipe.id,
      'title': recipe.title,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'calories': recipe.calories,
      'durationMinutes': recipe.durationMinutes,
      'difficulty': recipe.difficulty,
      'imageUrl': recipe.imageUrl,
      'category': recipe.category,
      'fiber': recipe.fiber,
    };
  }

  /// Map from List<Recipe> to List<Map<String, Object?>>
  static List<Map<String, Object?>> toMapList(List<Recipe> recipes) {
    return recipes.map((Recipe recipe) => toMap(recipe)).toList();
  }
}

