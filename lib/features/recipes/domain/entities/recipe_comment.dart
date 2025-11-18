/// Recipe comment entity - represents a comment on a recipe
/// Can be either global (visible to everyone) or household-only (visible only to household members)
class RecipeComment {
  /// Recipe comment constructor
  const RecipeComment({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    required this.isHouseholdOnly,
    this.avatarId,
    this.householdId,
  });

  /// Comment ID
  final String id;

  /// Recipe ID this comment belongs to
  final String recipeId;

  /// User ID who wrote the comment
  final String userId;

  /// User display name
  final String userName;

  /// Avatar ID
  final String? avatarId;

  /// Comment text
  final String text;

  /// Creation timestamp
  final DateTime createdAt;

  /// Whether this comment is household-only (true) or global (false)
  final bool isHouseholdOnly;

  /// Household ID (only set if isHouseholdOnly is true)
  final String? householdId;

  /// Create from JSON
  factory RecipeComment.fromJson(Map<String, dynamic> json) => RecipeComment(
    id: json['id'] as String,
    recipeId: json['recipeId'] as String,
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    avatarId: json['avatarId'] as String?,
    text: json['text'] as String,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    isHouseholdOnly: json['isHouseholdOnly'] as bool? ?? false,
    householdId: json['householdId'] as String?,
  );

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'recipeId': recipeId,
    'userId': userId,
    'userName': userName,
    'avatarId': avatarId,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'isHouseholdOnly': isHouseholdOnly,
    if (householdId != null) 'householdId': householdId,
  };

  /// Create a copy with modified fields
  RecipeComment copyWith({
    String? id,
    String? recipeId,
    String? userId,
    String? userName,
    String? avatarId,
    String? text,
    DateTime? createdAt,
    bool? isHouseholdOnly,
    String? householdId,
  }) => RecipeComment(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    avatarId: avatarId ?? this.avatarId,
    text: text ?? this.text,
    createdAt: createdAt ?? this.createdAt,
    isHouseholdOnly: isHouseholdOnly ?? this.isHouseholdOnly,
    householdId: householdId ?? this.householdId,
  );
}
