import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// Auth state - Presentation layer state management
@freezed
class AuthState with _$AuthState {
  /// Initial state
  const factory AuthState.initial() = _Initial;

  /// Loading state
  const factory AuthState.loading() = _Loading;

  /// Authenticated state
  const factory AuthState.authenticated(User user) = _Authenticated;

  /// Unauthenticated state
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Error state
  const factory AuthState.error(AuthFailure failure) = _Error;
}
