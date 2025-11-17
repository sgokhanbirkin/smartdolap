import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';

/// Shared recipe entity - recipe shared in household
class SharedRecipe {
  /// Shared recipe constructor
  const SharedRecipe({
    required this.id,
    required this.householdId,
    required this.sharedBy,
    required this.sharedByName,
    required this.recipe,
    this.avatarId,
    required this.createdAt,
  });

  /// Shared recipe ID
  final String id;

  /// Household ID
  final String householdId;

  /// User ID who shared
  final String sharedBy;

  /// User display name
  final String sharedByName;

  /// Avatar ID
  final String? avatarId;

  /// The shared recipe
  final UserRecipe recipe;

  /// Creation timestamp
  final DateTime createdAt;

  /// Create from JSON
  factory SharedRecipe.fromJson(Map<String, dynamic> json) => SharedRecipe(
    id: json['id'] as String,
    householdId: json['householdId'] as String,
    sharedBy: json['sharedBy'] as String,
    sharedByName: json['sharedByName'] as String,
    avatarId: json['avatarId'] as String?,
    recipe: UserRecipe.fromMap(json['recipe'] as Map<dynamic, dynamic>),
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'householdId': householdId,
    'sharedBy': sharedBy,
    'sharedByName': sharedByName,
    'avatarId': avatarId,
    'recipe': recipe.toMap(),
    'createdAt': createdAt.toIso8601String(),
  };

  SharedRecipe copyWith({
    String? id,
    String? householdId,
    String? sharedBy,
    String? sharedByName,
    String? avatarId,
    UserRecipe? recipe,
    DateTime? createdAt,
  }) =>
      SharedRecipe(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        sharedBy: sharedBy ?? this.sharedBy,
        sharedByName: sharedByName ?? this.sharedByName,
        avatarId: avatarId ?? this.avatarId,
        recipe: recipe ?? this.recipe,
        createdAt: createdAt ?? this.createdAt,
      );
}

