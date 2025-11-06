import 'package:smartdolap/features/auth/domain/entities/user.dart';

/// Auth repository interface - Domain layer abstraction
abstract class IAuthRepository {
  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current user
  Future<User?> getCurrentUser();

  /// Stream of current user
  Stream<User?> get currentUserStream;
}
