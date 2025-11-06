import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';

/// Logout use case - Business logic for user sign out
class LogoutUseCase {
  /// Logout use case constructor
  const LogoutUseCase(this.repository);

  /// Auth repository
  final IAuthRepository repository;

  /// Execute logout
  Future<void> call() => repository.signOut();
}
