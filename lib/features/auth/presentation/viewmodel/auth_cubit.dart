import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:smartdolap/features/auth/domain/use_cases/login_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/register_usecase.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/services/i_sync_service.dart';
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

      // Sync Firestore data to Hive after successful login
      try {
        await sl<ISyncService>().syncUserData(userId: user.id);
      } catch (e) {
        // Sync errors shouldn't block login
        // Logger will handle error logging
      }
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

      // Sync Firestore data to Hive after successful registration
      try {
        await sl<ISyncService>().syncUserData(userId: user.id);
      } catch (e) {
        // Sync errors shouldn't block registration
        // Logger will handle error logging
      }
    } on AuthFailure catch (failure) {
      emit(AuthState.error(failure));
    } on Exception catch (e) {
      emit(AuthState.error(AuthFailure.unknown(e.toString())));
    }
  }

  /// Refresh current user data (e.g., after household creation)
  Future<void> refreshUser() async {
    try {
      final User? currentUser = await repository.getCurrentUser();
      if (currentUser != null) {
        emit(AuthState.authenticated(currentUser));
      }
    } catch (e) {
      // Silently fail - don't emit error state on refresh
      debugPrint('[AuthCubit] Failed to refresh user: $e');
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
