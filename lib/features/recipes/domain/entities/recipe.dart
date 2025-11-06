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
}
