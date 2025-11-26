/// Meal type preferences - product selections for each meal type
class MealTypePreferences {
  /// Meal type preferences constructor
  const MealTypePreferences({
    this.breakfast = const <String>[],
    this.lunch = const <String>[],
    this.dinner = const <String>[],
    this.snack = const <String>[],
  });

  /// Create from JSON
  factory MealTypePreferences.fromJson(Map<String, dynamic> json) =>
      MealTypePreferences(
        breakfast: _parseStringList(json['breakfast'] as List<dynamic>?),
        lunch: _parseStringList(json['lunch'] as List<dynamic>?),
        dinner: _parseStringList(json['dinner'] as List<dynamic>?),
        snack: _parseStringList(json['snack'] as List<dynamic>?),
      );

  /// Breakfast products (product names)
  final List<String> breakfast;

  /// Lunch products (product names)
  final List<String> lunch;

  /// Dinner products (product names)
  final List<String> dinner;

  /// Snack products (product names)
  final List<String> snack;

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'breakfast': breakfast,
    'lunch': lunch,
    'dinner': dinner,
    'snack': snack,
  };

  /// Creates a modified copy with new values
  MealTypePreferences copyWith({
    List<String>? breakfast,
    List<String>? lunch,
    List<String>? dinner,
    List<String>? snack,
  }) => MealTypePreferences(
    breakfast: breakfast ?? this.breakfast,
    lunch: lunch ?? this.lunch,
    dinner: dinner ?? this.dinner,
    snack: snack ?? this.snack,
  );

  /// Get all products as a flat list
  List<String> get allProducts => <String>{
    ...breakfast,
    ...lunch,
    ...dinner,
    ...snack,
  }.toList(); // Remove duplicates
}

List<String> _parseStringList(List<dynamic>? source) {
  if (source == null) {
    return const <String>[];
  }
  return source.whereType<String>().toList();
}
