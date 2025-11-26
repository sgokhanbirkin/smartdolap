import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Auth guard mixin for protecting routes
mixin AuthGuard {
  /// Check if user is authenticated, redirect to login if not
  static bool checkAuth(BuildContext context) {
    final AuthState state = context.read<AuthCubit>().state;
    return state.maybeWhen(
      authenticated: (_) => true,
      orElse: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(AppRouter.login);
        });
        return false;
      },
    );
  }

  /// Get current user ID if authenticated, null otherwise
  static String? getUserId(BuildContext context) {
    final AuthState state = context.read<AuthCubit>().state;
    return state.maybeWhen(
      authenticated: (User user) => user.id,
      orElse: () => null,
    );
  }
}

/// Route guard widget that protects routes requiring authentication
class AuthGuardWidget extends StatefulWidget {
  const AuthGuardWidget({
    required this.child,
    this.redirectToLogin = true,
    super.key,
  });

  final Widget child;
  final bool redirectToLogin;

  @override
  State<AuthGuardWidget> createState() => _AuthGuardWidgetState();
}

class _AuthGuardWidgetState extends State<AuthGuardWidget> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
    listener: (BuildContext context, AuthState state) {
      if (_hasNavigated) {
        return;
      }

      state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {
          if (widget.redirectToLogin) {
            _hasNavigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(AppRouter.login);
              }
            });
          }
        },
        error: (_) {
          if (widget.redirectToLogin) {
            _hasNavigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(AppRouter.login);
              }
            });
          }
        },
      );
    },
    child: BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (AuthState previous, AuthState current) {
        // Only rebuild when authentication status changes (not on every state change)
        final bool wasAuthenticated = previous.maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        );
        final bool isAuthenticated = current.maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        );
        return wasAuthenticated != isAuthenticated;
      },
      builder: (BuildContext context, AuthState state) => state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          authenticated: (_) => widget.child,
          unauthenticated: () => const SizedBox.shrink(),
          error: (_) => const SizedBox.shrink(),
        ),
    ),
  );
}

