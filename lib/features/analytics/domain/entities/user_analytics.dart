import 'package:smartdolap/features/analytics/domain/entities/ingredient_usage.dart';

/// Represents user analytics data
class UserAnalytics {
  /// Creates user analytics
  const UserAnalytics({
    required this.userId,
    required this.householdId,
    required this.mealTimeDistribution,
    required this.mealTypeDistribution,
    required this.ingredientUsage,
    required this.categoryUsage,
    required this.dietaryPattern,
    required this.lastUpdated,
  });

  /// Create from JSON
  factory UserAnalytics.fromJson(Map<String, dynamic> json) => UserAnalytics(
    userId: json['userId'] as String,
    householdId: json['householdId'] as String,
    mealTimeDistribution:
        (json['mealTimeDistribution'] as Map<dynamic, dynamic>?)?.map(
          (key, value) => MapEntry(key as String, value as int),
        ) ??
        <String, int>{},
    mealTypeDistribution:
        (json['mealTypeDistribution'] as Map<dynamic, dynamic>?)?.map(
          (key, value) => MapEntry(key as String, value as int),
        ) ??
        <String, int>{},
    ingredientUsage:
        (json['ingredientUsage'] as Map<dynamic, dynamic>?)?.map(
          (key, value) => MapEntry(
            key as String,
            IngredientUsage.fromJson(value as Map<String, dynamic>),
          ),
        ) ??
        <String, IngredientUsage>{},
    categoryUsage:
        (json['categoryUsage'] as Map<dynamic, dynamic>?)?.map(
          (key, value) => MapEntry(key as String, value as int),
        ) ??
        <String, int>{},
    dietaryPattern:
        (json['dietaryPattern'] as Map<dynamic, dynamic>?)?.map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ) ??
        <String, double>{},
    lastUpdated: json['lastUpdated'] != null
        ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  /// User ID
  final String userId;

  /// Household ID
  final String householdId;

  /// Meal time distribution: {"08:00": 5, "12:00": 10}
  final Map<String, int> mealTimeDistribution;

  /// Meal type distribution: {"breakfast": 20, "lunch": 30}
  final Map<String, int> mealTypeDistribution;

  /// Ingredient usage statistics
  final Map<String, IngredientUsage> ingredientUsage;

  /// Category usage: {"dairy": 50, "vegetables": 30}
  final Map<String, int> categoryUsage;

  /// Dietary pattern: {"vegetable_heavy": 0.6, "protein_heavy": 0.3}
  final Map<String, double> dietaryPattern;

  /// Last update timestamp
  final DateTime lastUpdated;

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'householdId': householdId,
    'mealTimeDistribution': mealTimeDistribution,
    'mealTypeDistribution': mealTypeDistribution,
    'ingredientUsage': ingredientUsage.map(
      (String key, IngredientUsage value) => MapEntry(key, value.toJson()),
    ),
    'categoryUsage': categoryUsage,
    'dietaryPattern': dietaryPattern,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  UserAnalytics copyWith({
    String? userId,
    String? householdId,
    Map<String, int>? mealTimeDistribution,
    Map<String, int>? mealTypeDistribution,
    Map<String, IngredientUsage>? ingredientUsage,
    Map<String, int>? categoryUsage,
    Map<String, double>? dietaryPattern,
    DateTime? lastUpdated,
  }) => UserAnalytics(
    userId: userId ?? this.userId,
    householdId: householdId ?? this.householdId,
    mealTimeDistribution: mealTimeDistribution ?? this.mealTimeDistribution,
    mealTypeDistribution: mealTypeDistribution ?? this.mealTypeDistribution,
    ingredientUsage: ingredientUsage ?? this.ingredientUsage,
    categoryUsage: categoryUsage ?? this.categoryUsage,
    dietaryPattern: dietaryPattern ?? this.dietaryPattern,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
