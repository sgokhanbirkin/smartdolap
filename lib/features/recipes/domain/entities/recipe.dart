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
    final Object? stepsData = map['steps'];
    List<RecipeStep> stepsList = <RecipeStep>[];

    if (stepsData is List<dynamic> && stepsData.isNotEmpty) {
      final Object? firstItem = stepsData.first;
      if (firstItem is Map) {
        // It's a list of RecipeStep objects (stored as maps)
        stepsList = stepsData
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> e) =>
                  RecipeStep.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      } else if (firstItem is String) {
        // It's a list of strings (backward compatibility)
        stepsList = stepsData
            .whereType<String>()
            .map(RecipeStep.fromString)
            .toList();
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
