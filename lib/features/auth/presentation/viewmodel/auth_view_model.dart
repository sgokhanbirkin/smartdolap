import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:smartdolap/core/services/i_sync_service.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:smartdolap/features/auth/domain/use_cases/login_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/register_usecase.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';

/// AuthViewModel - Business logic orchestration for authentication
///
/// Responsibilities:
/// - Execute authentication use cases (login/register/logout)
/// - Listen to auth state changes from repository
/// - Coordinate sync operations after successful auth
/// - Update AuthCubit with new states
///
/// SOLID Principles:
/// - Single Responsibility: Handles only auth flow orchestration
/// - Open/Closed: Easily extendable with new auth flows
/// - Interface Segregation: Depends on precise use cases/repositories
/// - Dependency Inversion: Depends on abstractions instead of concretes
class AuthViewModel {
  AuthViewModel({
    required AuthCubit cubit,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RegisterUseCase registerUseCase,
    required IAuthRepository authRepository,
    required ISyncService syncService,
  })  : _cubit = cubit,
        _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _registerUseCase = registerUseCase,
        _authRepository = authRepository,
        _syncService = syncService;

  final AuthCubit _cubit;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RegisterUseCase _registerUseCase;
  final IAuthRepository _authRepository;
  final ISyncService _syncService;

  StreamSubscription<User?>? _authSubscription;

  /// Initializes view model by setting current user & listening to stream
  Future<void> initialize() async {
    final User? currentUser = await _authRepository.getCurrentUser();
    if (currentUser != null) {
      _cubit.setAuthenticated(currentUser);
    } else {
      _cubit.setUnauthenticated();
    }

    await _authSubscription?.cancel();
    _authSubscription = _authRepository.currentUserStream.listen(
      (User? user) {
        if (user != null) {
          _cubit.setAuthenticated(user);
        } else {
          _cubit.setUnauthenticated();
        }
      },
    );
  }

  /// Performs login operation
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _cubit.setLoading();
    try {
      final User user = await _loginUseCase(email: email, password: password);
      _cubit.setAuthenticated(user);
      await _syncUserData(user.id);
    } on AuthFailure catch (failure) {
      _cubit.setError(failure);
    } on Exception catch (e) {
      _cubit.setError(AuthFailure.unknown(e.toString()));
    }
  }

  /// Performs registration operation
  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _cubit.setLoading();
    try {
      final User user = await _registerUseCase(
        email: email,
        password: password,
        displayName: displayName,
      );
      _cubit.setAuthenticated(user);
      await _syncUserData(user.id);
    } on AuthFailure catch (failure) {
      _cubit.setError(failure);
    } on Exception catch (e) {
      _cubit.setError(AuthFailure.unknown(e.toString()));
    }
  }

  /// Refreshes current user data from repository
  Future<void> refreshUser() async {
    try {
      final User? currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        _cubit.setAuthenticated(currentUser);
      } else {
        _cubit.setUnauthenticated();
      }
    } on Exception catch (e) {
      debugPrint('[AuthViewModel] Failed to refresh user: $e');
    }
  }

  /// Performs logout operation
  Future<void> logout() async {
    _cubit.setLoading();
    try {
      await _logoutUseCase();
      _cubit.setUnauthenticated();
    } on AuthFailure catch (failure) {
      _cubit.setError(failure);
    } on Exception catch (e) {
      _cubit.setError(AuthFailure.unknown(e.toString()));
    }
  }

  /// Disposes internal subscriptions
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
  }

  Future<void> _syncUserData(String userId) async {
    try {
      await _syncService.syncUserData(userId: userId);
    } on Exception catch (e) {
      debugPrint('[AuthViewModel] Sync failed: $e');
    }
  }
}

