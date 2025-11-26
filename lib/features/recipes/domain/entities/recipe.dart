// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/recipes/domain/entities/recipe_step.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.calories,
    this.durationMinutes,
    this.difficulty,
    this.imageUrl,
    this.category,
    this.missingCount,
    this.fiber,
  });

  factory Recipe.fromMap(Map<dynamic, dynamic> map) {
    final dynamic stepsData = map['steps'];
    List<RecipeStep> stepsList = <RecipeStep>[];
    
    if (stepsData != null) {
      if (stepsData is List<dynamic>) {
        // Check if it's a list of RecipeStep objects or strings
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
    }

    return Recipe(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      ingredients:
          (map['ingredients'] as List<dynamic>? ?? <dynamic>[])
              .cast<String>(),
      steps: stepsList,
      calories: (map['calories'] as num?)?.toInt(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt(),
      difficulty: map['difficulty'] as String?,
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String?,
      missingCount: (map['missingCount'] as num?)?.toInt(),
      fiber: (map['fiber'] as num?)?.toInt(),
    );
  }

  final String id;
  final String title;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final int? calories;
  final int? durationMinutes;
  final String? difficulty;
  final String? imageUrl;
  final String? category;
  final int? missingCount;
  final int? fiber; // gram cinsinden lif (opsiyonel)

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'ingredients': ingredients,
        'steps': steps.map((RecipeStep step) => step.toJson()).toList(),
        'calories': calories,
        'durationMinutes': durationMinutes,
        'difficulty': difficulty,
        'imageUrl': imageUrl,
        'category': category,
        'missingCount': missingCount,
        'fiber': fiber,
      };

  /// Get steps as simple strings (backward compatibility)
  List<String> get stepsAsStrings => steps.map((RecipeStep step) => step.description).toList();
}
