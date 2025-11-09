import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Service responsible for mapping Firestore documents to Recipe entities
/// Follows Single Responsibility Principle - only handles Firestore document mapping
class FirestoreRecipeMapper {
  /// Map Firestore DocumentSnapshot to Recipe
  static Recipe fromDocumentSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? {};
    return _mapDataToRecipe(data, doc.id);
  }

  /// Map Firestore QuerySnapshot to List<Recipe>
  static List<Recipe> fromQuerySnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) => fromDocumentSnapshot(doc)).toList();
  }

  /// Map Firestore data Map to Recipe
  static Recipe fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return _mapDataToRecipe(data, documentId);
  }

  /// Map List<DocumentSnapshot> to List<Recipe>
  static List<Recipe> fromDocumentSnapshots(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map((doc) => fromDocumentSnapshot(doc)).toList();
  }

  /// Internal helper to map data to Recipe
  static Recipe _mapDataToRecipe(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      title: data['title'] as String? ?? '',
      ingredients: (data['ingredients'] as List<dynamic>?)
              ?.map<String>((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      steps: (data['steps'] as List<dynamic>?)
              ?.map<String>((dynamic e) => e.toString())
              .toList() ??
          <String>[],
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
    return <String, dynamic>{
      'title': recipe.title,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'calories': recipe.calories,
      'durationMinutes': recipe.durationMinutes,
      'difficulty': recipe.difficulty,
      'imageUrl': recipe.imageUrl,
      'category': recipe.category,
      'missingCount': recipe.missingCount,
      'fiber': recipe.fiber,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}

