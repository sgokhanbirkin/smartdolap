/// Represents a meal consumption record
/// Tracks when and what users eat for analytics
class MealConsumption {
  /// Creates a meal consumption record
  const MealConsumption({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.recipeId,
    required this.recipeTitle,
    required this.ingredients,
    required this.meal,
    required this.consumedAt,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory MealConsumption.fromJson(Map<String, dynamic> json) =>
      MealConsumption(
        id: json['id'] as String,
        householdId: json['householdId'] as String,
        userId: json['userId'] as String,
        recipeId: json['recipeId'] as String,
        recipeTitle: json['recipeTitle'] as String,
        ingredients: _parseIngredients(json['ingredients'] as List<dynamic>?),
        meal: json['meal'] as String,
        consumedAt: json['consumedAt'] != null
            ? DateTime.tryParse(json['consumedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  /// Unique identifier
  final String id;

  /// Household ID
  final String householdId;

  /// User ID who consumed the meal
  final String userId;

  /// Recipe ID
  final String recipeId;

  /// Recipe title
  final String recipeTitle;

  /// Ingredients used in the recipe
  final List<String> ingredients;

  /// Meal type: "breakfast", "lunch", "dinner", "snack"
  final String meal;

  /// When the meal was consumed
  final DateTime consumedAt;

  /// When the record was created
  final DateTime createdAt;

  /// Convert to Firestore document
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'householdId': householdId,
    'userId': userId,
    'recipeId': recipeId,
    'recipeTitle': recipeTitle,
    'ingredients': ingredients,
    'meal': meal,
    'consumedAt': consumedAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  MealConsumption copyWith({
    String? id,
    String? householdId,
    String? userId,
    String? recipeId,
    String? recipeTitle,
    List<String>? ingredients,
    String? meal,
    DateTime? consumedAt,
    DateTime? createdAt,
  }) => MealConsumption(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    userId: userId ?? this.userId,
    recipeId: recipeId ?? this.recipeId,
    recipeTitle: recipeTitle ?? this.recipeTitle,
    ingredients: ingredients ?? this.ingredients,
    meal: meal ?? this.meal,
    consumedAt: consumedAt ?? this.consumedAt,
    createdAt: createdAt ?? this.createdAt,
  );
}

List<String> _parseIngredients(List<dynamic>? raw) {
  if (raw == null) {
    return <String>[];
  }
  return raw.whereType<String>().map((String value) => value).toList();
}
