import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

/// Auth failure model - Represents authentication errors
@freezed
class AuthFailure with _$AuthFailure {
  /// Invalid credentials failure
  const factory AuthFailure.invalidCredentials() = InvalidCredentialsFailure;

  /// Email already in use failure
  const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUseFailure;

  /// Weak password failure
  const factory AuthFailure.weakPassword() = WeakPasswordFailure;

  /// Network failure
  const factory AuthFailure.network() = NetworkFailure;

  /// Unknown failure
  const factory AuthFailure.unknown([String? message]) = UnknownFailure;
}
