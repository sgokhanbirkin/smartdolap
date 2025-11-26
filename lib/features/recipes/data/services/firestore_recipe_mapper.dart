import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_step.dart';

/// Service responsible for mapping Firestore documents to Recipe entities
/// Follows Single Responsibility Principle - only handles Firestore document mapping
class FirestoreRecipeMapper {
  /// Map Firestore DocumentSnapshot to Recipe
  static Recipe fromDocumentSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return _mapDataToRecipe(data, doc.id);
  }

  /// Map Firestore QuerySnapshot to list of Recipe entities.
  static List<Recipe> fromQuerySnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => snapshot.docs.map(fromDocumentSnapshot).toList();

  /// Map Firestore data map to a `Recipe` entity.
  static Recipe fromMap(Map<String, dynamic> data, String documentId) =>
      _mapDataToRecipe(data, documentId);

  /// Map list of `DocumentSnapshot` to list of `Recipe` entities.
  static List<Recipe> fromDocumentSnapshots(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) => docs.map(fromDocumentSnapshot).toList();

  /// Internal helper to map data to Recipe
  static Recipe _mapDataToRecipe(Map<String, dynamic> data, String id) {
    // Parse steps - handle both string list and RecipeStep list
    final Object? stepsData = data['steps'];
    List<RecipeStep> stepsList = <RecipeStep>[];

    if (stepsData != null && stepsData is List<dynamic>) {
      if (stepsData.isNotEmpty) {
        final Object? firstItem = stepsData.first;
        if (firstItem is Map) {
          // It's a list of RecipeStep objects
          stepsList = stepsData
              .whereType<Map<String, dynamic>>()
              .map(RecipeStep.fromJson)
              .toList();
        } else if (firstItem is String) {
          // It's a list of strings (backward compatibility)
          stepsList = stepsData
              .whereType<String>()
              .map(RecipeStep.fromString)
              .toList();
        }
      }
    }

    return Recipe(
      id: id,
      title: data['title'] as String? ?? '',
      ingredients: _mapIngredients(data['ingredients'] as List<dynamic>?),
      steps: stepsList,
      calories: data['calories'] as int?,
      durationMinutes: data['durationMinutes'] as int?,
      difficulty: data['difficulty'] as String?,
      imageUrl: data['imageUrl'] as String?,
      category: data['category'] as String?,
      missingCount: data['missingCount'] as int?,
      fiber: (data['fiber'] as num?)?.toInt(),
    );
  }

  /// Map Recipe to Firestore data Map
  static Map<String, dynamic> toMap(Recipe recipe) {
    final Map<String, dynamic> recipeMap = recipe.toMap();
    recipeMap['createdAt'] = DateTime.now().toIso8601String();
    return recipeMap;
  }
}

List<String> _mapIngredients(List<dynamic>? raw) {
  if (raw == null) {
    return <String>[];
  }
  return raw.map<String>((Object? value) => value.toString()).toList();
}
