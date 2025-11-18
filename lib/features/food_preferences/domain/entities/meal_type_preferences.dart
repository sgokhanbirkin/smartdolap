/// Meal type preferences - product selections for each meal type
class MealTypePreferences {
  /// Meal type preferences constructor
  const MealTypePreferences({
    this.breakfast = const <String>[],
    this.lunch = const <String>[],
    this.dinner = const <String>[],
    this.snack = const <String>[],
  });

  /// Breakfast products (product names)
  final List<String> breakfast;

  /// Lunch products (product names)
  final List<String> lunch;

  /// Dinner products (product names)
  final List<String> dinner;

  /// Snack products (product names)
  final List<String> snack;

  /// Create from JSON
  factory MealTypePreferences.fromJson(Map<String, dynamic> json) =>
      MealTypePreferences(
        breakfast: (json['breakfast'] as List<dynamic>?)
                ?.map((dynamic e) => e as String)
                .toList() ??
            const <String>[],
        lunch: (json['lunch'] as List<dynamic>?)
                ?.map((dynamic e) => e as String)
                .toList() ??
            const <String>[],
        dinner: (json['dinner'] as List<dynamic>?)
                ?.map((dynamic e) => e as String)
                .toList() ??
            const <String>[],
        snack: (json['snack'] as List<dynamic>?)
                ?.map((dynamic e) => e as String)
                .toList() ??
            const <String>[],
      );

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
  }) =>
      MealTypePreferences(
        breakfast: breakfast ?? this.breakfast,
        lunch: lunch ?? this.lunch,
        dinner: dinner ?? this.dinner,
        snack: snack ?? this.snack,
      );

  /// Get all products as a flat list
  List<String> get allProducts => <String>[
        ...breakfast,
        ...lunch,
        ...dinner,
        ...snack,
      ].toSet().toList(); // Remove duplicates
}

