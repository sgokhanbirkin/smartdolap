import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      authenticated: (user) => user.id,
      orElse: () => null,
    );
  }
}

/// Route guard widget that protects routes requiring authentication
class AuthGuardWidget extends StatelessWidget {
  const AuthGuardWidget({
    required this.child,
    this.redirectToLogin = true,
    super.key,
  });

  final Widget child;
  final bool redirectToLogin;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (BuildContext context, AuthState state) {
      return state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        authenticated: (_) => child,
        unauthenticated: () {
          if (redirectToLogin) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
            });
          }
          return const SizedBox.shrink();
        },
        error: (_) {
          if (redirectToLogin) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
            });
          }
          return const SizedBox.shrink();
        },
      );
    },
  );
}

