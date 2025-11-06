import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';

/// Register use case - Business logic for user registration
class RegisterUseCase {
  /// Register use case constructor
  const RegisterUseCase(this.repository);

  /// Auth repository
  final IAuthRepository repository;

  /// Execute registration
  Future<User> call({
    required String email,
    required String password,
    String? displayName,
  }) => repository.signUpWithEmailAndPassword(
    email: email,
    password: password,
    displayName: displayName,
  );
}
