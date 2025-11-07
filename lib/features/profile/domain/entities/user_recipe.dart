/// Represents a detailed recipe contributed by the user or AI.
class UserRecipe {
  /// Creates a recipe model.
  const UserRecipe({
    required this.id,
    required this.title,
    this.description = '',
    this.ingredients = const <String>[],
    this.steps = const <String>[],
    this.imagePath,
    this.videoPath,
    this.tags = const <String>[],
    this.isAIRecommendation = false,
    this.createdAt,
  });

  /// Restores a recipe from a stored map.
  factory UserRecipe.fromMap(Map<dynamic, dynamic> map) => UserRecipe(
    id: (map['id'] as String?) ?? '',
    title: (map['title'] as String?) ?? '',
    description: (map['description'] as String?) ?? '',
    ingredients:
        (map['ingredients'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    steps: (map['steps'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    imagePath: map['imagePath'] as String?,
    videoPath: map['videoPath'] as String?,
    tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    isAIRecommendation: map['isAIRecommendation'] as bool? ?? false,
    createdAt: map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt'] as String)
        : null,
  );

  /// Unique identifier for the recipe.
  final String id;
  /// Human readable title shown in UI.
  final String title;
  /// Longer description or story for the recipe.
  final String description;
  /// Ingredient list captured from the form.
  final List<String> ingredients;
  /// Preparation steps provided by the user.
  final List<String> steps;
  /// Optional local image attachment.
  final String? imagePath;
  /// Optional local video attachment.
  final String? videoPath;
  /// Tags/chips describing the recipe.
  final List<String> tags;
  /// Whether the recipe originated from AI suggestions.
  final bool isAIRecommendation;
  /// Creation timestamp.
  final DateTime? createdAt;

  /// Serializes the entity for persistence.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'ingredients': ingredients,
    'steps': steps,
    'imagePath': imagePath,
    'videoPath': videoPath,
    'tags': tags,
    'isAIRecommendation': isAIRecommendation,
    'createdAt': createdAt?.toIso8601String(),
  };

}
