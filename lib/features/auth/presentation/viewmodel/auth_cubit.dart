import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:smartdolap/features/auth/domain/use_cases/login_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/register_usecase.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';

/// Auth cubit - Presentation layer view model
class AuthCubit extends Cubit<AuthState> {
  /// Auth cubit constructor
  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.registerUseCase,
    required this.repository,
  }) : super(const AuthState.initial()) {
    _initialize();
  }

  /// Login use case
  final LoginUseCase loginUseCase;

  /// Logout use case
  final LogoutUseCase logoutUseCase;

  /// Register use case
  final RegisterUseCase registerUseCase;

  /// Auth repository
  final IAuthRepository repository;

  /// Initialize and listen to auth state changes
  Future<void> _initialize() async {
    // Check current user
    final User? currentUser = await repository.getCurrentUser();
    if (currentUser != null) {
      emit(AuthState.authenticated(currentUser));
    } else {
      emit(const AuthState.unauthenticated());
    }

    // Listen to auth state changes
    repository.currentUserStream.listen((User? user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    emit(const AuthState.loading());
    try {
      final User user = await loginUseCase(email: email, password: password);
      emit(AuthState.authenticated(user));
    } on AuthFailure catch (failure) {
      emit(AuthState.error(failure));
    } on Exception catch (e) {
      emit(AuthState.error(AuthFailure.unknown(e.toString())));
    }
  }

  /// Register with email and password
  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(const AuthState.loading());
    try {
      final User user = await registerUseCase(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(AuthState.authenticated(user));
    } on AuthFailure catch (failure) {
      emit(AuthState.error(failure));
    } on Exception catch (e) {
      emit(AuthState.error(AuthFailure.unknown(e.toString())));
    }
  }

  /// Logout current user
  Future<void> logout() async {
    emit(const AuthState.loading());
    try {
      await logoutUseCase();
      emit(const AuthState.unauthenticated());
    } on AuthFailure catch (failure) {
      emit(AuthState.error(failure));
    } on Exception catch (e) {
      emit(AuthState.error(AuthFailure.unknown(e.toString())));
    }
  }
}
