import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';

/// Login use case - Business logic for user authentication
class LoginUseCase {
  /// Login use case constructor
  const LoginUseCase(this.repository);

  /// Auth repository
  final IAuthRepository repository;

  /// Execute login
  Future<User> call({required String email, required String password}) =>
      repository.signInWithEmailAndPassword(email: email, password: password);
}
