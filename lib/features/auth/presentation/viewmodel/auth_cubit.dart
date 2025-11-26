import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';

/// AuthCubit - State management layer (MVVM pattern)
///
/// Responsibilities:
/// - Emit auth states (loading, authenticated, unauthenticated, error)
/// - Do **not** contain any business logic (delegated to AuthViewModel)
///
/// SOLID Principles:
/// - Single Responsibility: Only handles state emission
/// - Open/Closed: New states can be added without modifying existing methods
/// - Dependency Inversion: Depends only on AuthState abstractions
class AuthCubit extends Cubit<AuthState> {
  /// Creates an AuthCubit instance
  AuthCubit() : super(const AuthState.initial());

  /// Emits loading state
  void setLoading() => emit(const AuthState.loading());

  /// Emits authenticated state with the given user
  void setAuthenticated(User user) => emit(AuthState.authenticated(user));

  /// Emits unauthenticated state
  void setUnauthenticated() => emit(const AuthState.unauthenticated());

  /// Emits error state with given failure
  void setError(AuthFailure failure) => emit(AuthState.error(failure));
}
