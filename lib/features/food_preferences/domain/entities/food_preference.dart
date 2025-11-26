/// Food preference entity - represents a food item that users can select
class FoodPreference {
  /// Food preference constructor
  const FoodPreference({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
    this.createdAt,
  });

  /// Create from JSON
  factory FoodPreference.fromJson(Map<String, dynamic> json) => FoodPreference(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        icon: json['icon'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

  /// Food preference ID
  final String id;

  /// Food name (localized)
  final String name;

  /// Category (turkish, italian, asian, breakfast, dessert, etc.)
  final String category;

  /// Optional icon name
  final String? icon;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'category': category,
        if (icon != null) 'icon': icon,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  /// Creates a modified copy with new values
  FoodPreference copyWith({
    String? id,
    String? name,
    String? category,
    String? icon,
    DateTime? createdAt,
  }) =>
      FoodPreference(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        icon: icon ?? this.icon,
        createdAt: createdAt ?? this.createdAt,
      );
}

