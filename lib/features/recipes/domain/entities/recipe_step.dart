// ignore_for_file: public_member_api_docs

/// Recipe step entity - represents a detailed cooking step
class RecipeStep {
  /// Recipe step constructor
  const RecipeStep({
    required this.description,
    this.durationMinutes,
    this.stepType,
    this.temperature,
    this.tips,
  });

  /// Create from JSON
  factory RecipeStep.fromJson(Map<String, dynamic> json) => RecipeStep(
        description: json['description'] as String? ?? '',
        durationMinutes: json['durationMinutes'] as int?,
        stepType: json['stepType'] as String?,
        temperature: json['temperature'] as int?,
        tips: json['tips'] as String?,
      );

  /// Create from simple string (backward compatibility)
  factory RecipeStep.fromString(String description) => RecipeStep(
        description: description,
      );

  /// Step description (detailed)
  final String description;

  /// Duration in minutes for this step (optional)
  final int? durationMinutes;

  /// Step type: 'prep', 'cook', 'bake', 'rest', 'serve', etc.
  final String? stepType;

  /// Temperature in Celsius (optional, for baking/cooking)
  final int? temperature;

  /// Additional tips for this step (optional)
  final String? tips;

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'description': description,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (stepType != null) 'stepType': stepType,
        if (temperature != null) 'temperature': temperature,
        if (tips != null) 'tips': tips,
      };

  /// Convert to simple string (backward compatibility)
  @override
  String toString() => description;

  /// Create a copy with modified fields
  RecipeStep copyWith({
    String? description,
    int? durationMinutes,
    String? stepType,
    int? temperature,
    String? tips,
  }) =>
      RecipeStep(
        description: description ?? this.description,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        stepType: stepType ?? this.stepType,
        temperature: temperature ?? this.temperature,
        tips: tips ?? this.tips,
      );
}

