import 'package:smartdolap/features/food_preferences/domain/entities/meal_type_preferences.dart';

/// User food preferences - stores user's food selections and meal type preferences
class UserFoodPreferences {
  /// User food preferences constructor
  const UserFoodPreferences({
    required this.userId,
    required this.householdId,
    this.selectedFoodIds = const <String>[],
    this.mealTypePreferences = const MealTypePreferences(),
    this.completedAt,
    this.isCompleted = false,
  });

  /// Create from JSON
  factory UserFoodPreferences.fromJson(Map<String, dynamic> json) =>
      UserFoodPreferences(
        userId: json['userId'] as String,
        householdId: json['householdId'] as String,
        selectedFoodIds: (json['selectedFoodIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const <String>[],
        mealTypePreferences: json['mealTypePreferences'] != null
            ? MealTypePreferences.fromJson(
                json['mealTypePreferences'] as Map<String, dynamic>,
              )
            : const MealTypePreferences(),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  /// User ID
  final String userId;

  /// Household ID
  final String householdId;

  /// Selected food preference IDs
  final List<String> selectedFoodIds;

  /// Meal type preferences (breakfast, lunch, dinner, snack products)
  final MealTypePreferences mealTypePreferences;

  /// Completion timestamp
  final DateTime? completedAt;

  /// Whether onboarding is completed
  final bool isCompleted;

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'userId': userId,
        'householdId': householdId,
        'selectedFoodIds': selectedFoodIds,
        'mealTypePreferences': mealTypePreferences.toJson(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        'isCompleted': isCompleted,
      };

  /// Creates a modified copy with new values
  UserFoodPreferences copyWith({
    String? userId,
    String? householdId,
    List<String>? selectedFoodIds,
    MealTypePreferences? mealTypePreferences,
    DateTime? completedAt,
    bool? isCompleted,
  }) =>
      UserFoodPreferences(
        userId: userId ?? this.userId,
        householdId: householdId ?? this.householdId,
        selectedFoodIds: selectedFoodIds ?? this.selectedFoodIds,
        mealTypePreferences: mealTypePreferences ?? this.mealTypePreferences,
        completedAt: completedAt ?? this.completedAt,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

