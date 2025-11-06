import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:smartdolap/features/auth/domain/entities/user.dart';

/// User model - Data layer representation
class UserModel extends User {
  /// User model constructor
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String?,
    photoUrl: json['photoUrl'] as String?,
  );

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(fb.User firebaseUser) => UserModel(
    id: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    displayName: firebaseUser.displayName,
    photoUrl: firebaseUser.photoURL,
  );

  /// Convert to domain entity
  User toEntity() =>
      User(id: id, email: email, displayName: displayName, photoUrl: photoUrl);

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
  };
}
