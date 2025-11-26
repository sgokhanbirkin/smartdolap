/// Household entity - represents a shared home/group
class Household {
  /// Household constructor
  const Household({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    this.members = const <HouseholdMember>[],
  });

  /// Create from JSON
  factory Household.fromJson(Map<String, dynamic> json) => Household(
    id: json['id'] as String,
    name: json['name'] as String,
    ownerId: json['ownerId'] as String,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    members:
        (json['members'] as List<dynamic>?)
            ?.map((e) => HouseholdMember.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <HouseholdMember>[],
  );

  /// Household ID
  final String id;

  /// Household name (e.g., "Evimiz", "Aile")
  final String name;

  /// Owner user ID
  final String ownerId;

  /// Creation timestamp
  final DateTime createdAt;

  /// List of household members
  final List<HouseholdMember> members;

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'ownerId': ownerId,
    'createdAt': createdAt.toIso8601String(),
    'members': members.map((HouseholdMember m) => m.toJson()).toList(),
  };

  Household copyWith({
    String? id,
    String? name,
    String? ownerId,
    DateTime? createdAt,
    List<HouseholdMember>? members,
  }) => Household(
    id: id ?? this.id,
    name: name ?? this.name,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    members: members ?? this.members,
  );
}

/// Household member entity
class HouseholdMember {
  /// Household member constructor
  const HouseholdMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userName,
    this.avatarId,
  });

  /// Create from JSON
  factory HouseholdMember.fromJson(Map<String, dynamic> json) =>
      HouseholdMember(
        userId: json['userId'] as String,
        userName: json['userName'] as String?,
        avatarId: json['avatarId'] as String?,
        role: json['role'] as String,
        joinedAt: json['joinedAt'] != null
            ? DateTime.tryParse(json['joinedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  /// User ID
  final String userId;

  /// User display name
  final String? userName;

  /// Avatar ID (for avatar selection)
  final String? avatarId;

  /// Member role: "owner" or "member"
  final String role;

  /// Join timestamp
  final DateTime joinedAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'userName': userName,
    'avatarId': avatarId,
    'role': role,
    'joinedAt': joinedAt.toIso8601String(),
  };

  HouseholdMember copyWith({
    String? userId,
    String? userName,
    String? avatarId,
    String? role,
    DateTime? joinedAt,
  }) => HouseholdMember(
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    avatarId: avatarId ?? this.avatarId,
    role: role ?? this.role,
    joinedAt: joinedAt ?? this.joinedAt,
  );
}
