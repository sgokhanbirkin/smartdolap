/// Represents ingredient usage statistics
class IngredientUsage {
  /// Creates ingredient usage statistics
  const IngredientUsage({
    required this.ingredientName,
    required this.totalUsed,
    required this.averageDailyUsage,
    required this.usageDates,
    required this.usageByMeal,
    required this.lastUsed,
  });

  /// Create from JSON
  factory IngredientUsage.fromJson(Map<String, dynamic> json) =>
      IngredientUsage(
        ingredientName: json['ingredientName'] as String,
        totalUsed: json['totalUsed'] as int? ?? 0,
        averageDailyUsage:
            (json['averageDailyUsage'] as num?)?.toDouble() ?? 0.0,
        usageDates:
            (json['usageDates'] as List<dynamic>?)
                ?.map((e) => DateTime.tryParse(e as String) ?? DateTime.now())
                .toList() ??
            <DateTime>[],
        usageByMeal:
            (json['usageByMeal'] as Map<dynamic, dynamic>?)?.map(
              (key, value) => MapEntry(key as String, value as int),
            ) ??
            <String, int>{},
        lastUsed: json['lastUsed'] != null
            ? DateTime.tryParse(json['lastUsed'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  /// Ingredient name
  final String ingredientName;

  /// Total times used
  final int totalUsed;

  /// Average daily usage (calculated from usageDates)
  final double averageDailyUsage;

  /// List of dates when ingredient was used
  final List<DateTime> usageDates;

  /// Usage count by meal type
  final Map<String, int> usageByMeal;

  /// Last time ingredient was used
  final DateTime lastUsed;

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'ingredientName': ingredientName,
    'totalUsed': totalUsed,
    'averageDailyUsage': averageDailyUsage,
    'usageDates': usageDates.map((DateTime e) => e.toIso8601String()).toList(),
    'usageByMeal': usageByMeal,
    'lastUsed': lastUsed.toIso8601String(),
  };

  IngredientUsage copyWith({
    String? ingredientName,
    int? totalUsed,
    double? averageDailyUsage,
    List<DateTime>? usageDates,
    Map<String, int>? usageByMeal,
    DateTime? lastUsed,
  }) => IngredientUsage(
    ingredientName: ingredientName ?? this.ingredientName,
    totalUsed: totalUsed ?? this.totalUsed,
    averageDailyUsage: averageDailyUsage ?? this.averageDailyUsage,
    usageDates: usageDates ?? this.usageDates,
    usageByMeal: usageByMeal ?? this.usageByMeal,
    lastUsed: lastUsed ?? this.lastUsed,
  );
}
