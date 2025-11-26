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

  /// Map Firestore QuerySnapshot to List<Recipe>
  static List<Recipe> fromQuerySnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => snapshot.docs.map(fromDocumentSnapshot).toList();

  /// Map Firestore data Map to Recipe
  static Recipe fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) => _mapDataToRecipe(data, documentId);

  /// Map List<DocumentSnapshot> to List<Recipe>
  static List<Recipe> fromDocumentSnapshots(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) => docs.map(fromDocumentSnapshot).toList();

  /// Internal helper to map data to Recipe
  static Recipe _mapDataToRecipe(Map<String, dynamic> data, String id) {
    // Parse steps - handle both string list and RecipeStep list
    final dynamic stepsData = data['steps'];
    List<RecipeStep> stepsList = <RecipeStep>[];
    
    if (stepsData != null && stepsData is List<dynamic>) {
      if (stepsData.isNotEmpty) {
        final dynamic firstItem = stepsData.first;
        if (firstItem is Map) {
          // It's a list of RecipeStep objects
          stepsList = stepsData
              .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (firstItem is String) {
          // It's a list of strings (backward compatibility)
          stepsList = stepsData
              .map((e) => RecipeStep.fromString(e as String))
              .toList();
        }
      }
    }

    return Recipe(
      id: id,
      title: data['title'] as String? ?? '',
      ingredients: (data['ingredients'] as List<dynamic>?)
              ?.map<String>((e) => e.toString())
              .toList() ??
          <String>[],
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

