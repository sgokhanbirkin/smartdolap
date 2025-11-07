// ignore_for_file: public_member_api_docs

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

  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;
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
        'steps': steps,
        'calories': calories,
        'durationMinutes': durationMinutes,
        'difficulty': difficulty,
        'imageUrl': imageUrl,
        'category': category,
        'missingCount': missingCount,
        'fiber': fiber,
      };

  factory Recipe.fromMap(Map<dynamic, dynamic> map) => Recipe(
        id: (map['id'] as String?) ?? '',
        title: (map['title'] as String?) ?? '',
        ingredients:
            (map['ingredients'] as List<dynamic>? ?? <dynamic>[])
                .cast<String>(),
        steps: (map['steps'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
        calories: (map['calories'] as num?)?.toInt(),
        durationMinutes: (map['durationMinutes'] as num?)?.toInt(),
        difficulty: map['difficulty'] as String?,
        imageUrl: map['imageUrl'] as String?,
        category: map['category'] as String?,
        missingCount: (map['missingCount'] as num?)?.toInt(),
        fiber: (map['fiber'] as num?)?.toInt(),
      );
}
