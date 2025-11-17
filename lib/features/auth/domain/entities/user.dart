/// User entity - Domain layer business object
class User {
  /// User constructor
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.householdId,
    this.avatarId,
  });

  /// User ID
  final String id;

  /// User email
  final String email;

  /// User display name
  final String? displayName;

  /// User photo URL
  final String? photoUrl;

  /// Household ID (null if not in a household)
  final String? householdId;

  /// Avatar ID (for avatar selection)
  final String? avatarId;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? householdId,
    String? avatarId,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        householdId: householdId ?? this.householdId,
        avatarId: avatarId ?? this.avatarId,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.householdId == householdId &&
        other.avatarId == avatarId;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      householdId.hashCode ^
      avatarId.hashCode;
}
