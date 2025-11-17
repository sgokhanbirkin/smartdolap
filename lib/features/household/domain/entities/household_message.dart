/// Household message entity - for general messaging and recipe sharing
class HouseholdMessage {
  /// Household message constructor
  const HouseholdMessage({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.userName,
    this.recipeId,
    this.text,
    this.avatarId,
    required this.createdAt,
  });

  /// Message ID
  final String id;

  /// Household ID
  final String householdId;

  /// User ID who sent the message
  final String userId;

  /// User display name
  final String userName;

  /// Avatar ID
  final String? avatarId;

  /// Optional message text
  final String? text;

  /// Shared recipe ID (optional - only if message is about a recipe)
  final String? recipeId;

  /// Creation timestamp
  final DateTime createdAt;

  /// Create from JSON
  factory HouseholdMessage.fromJson(Map<String, dynamic> json) =>
      HouseholdMessage(
        id: json['id'] as String,
        householdId: json['householdId'] as String,
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        avatarId: json['avatarId'] as String?,
        text: json['text'] as String?,
        recipeId: json['recipeId'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'householdId': householdId,
    'userId': userId,
    'userName': userName,
    'avatarId': avatarId,
    'text': text,
    if (recipeId != null) 'recipeId': recipeId,
    'createdAt': createdAt.toIso8601String(),
  };

  HouseholdMessage copyWith({
    String? id,
    String? householdId,
    String? userId,
    String? userName,
    String? avatarId,
    String? text,
    String? recipeId,
    DateTime? createdAt,
  }) =>
      HouseholdMessage(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        avatarId: avatarId ?? this.avatarId,
        text: text ?? this.text,
        recipeId: recipeId ?? this.recipeId,
        createdAt: createdAt ?? this.createdAt,
      );
}

