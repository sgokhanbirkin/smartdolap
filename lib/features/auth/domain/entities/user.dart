/// User entity - Domain layer business object
class User {
  /// User constructor
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  /// User ID
  final String id;

  /// User email
  final String email;

  /// User display name
  final String? displayName;

  /// User photo URL
  final String? photoUrl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^ email.hashCode ^ displayName.hashCode ^ photoUrl.hashCode;
}
