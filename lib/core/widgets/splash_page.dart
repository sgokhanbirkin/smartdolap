import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Splash screen - Shows logo and loading message
/// Automatically redirects based on auth state
class SplashPage extends StatefulWidget {
  /// Splash page constructor
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('[SplashPage] Splash screen initialized');
    // Wait 2-3 seconds before checking auth state
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _checkAuthState();
      }
    });
  }

  void _checkAuthState() {
    final AuthCubit authCubit = context.read<AuthCubit>();
    final AuthState currentState = authCubit.state;

    debugPrint('[SplashPage] Checking auth state: $currentState');

    currentState.when(
      initial: () {
        debugPrint('[SplashPage] Initial state - waiting for auth check');
        // AuthCubit will emit authenticated/unauthenticated soon
      },
      loading: () {
        debugPrint('[SplashPage] Loading state - waiting');
      },
      authenticated: (user) {
        debugPrint('[SplashPage] Authenticated - redirecting to home');
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      },
      unauthenticated: () {
        debugPrint('[SplashPage] Unauthenticated - redirecting to login');
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      },
      error: (failure) {
        debugPrint('[SplashPage] Error state - redirecting to login');
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
    listener: (BuildContext context, AuthState state) {
      debugPrint('[SplashPage] AuthState changed: $state');
      state.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          debugPrint(
            '[SplashPage] Authenticated during splash - redirecting to home',
          );
          Navigator.of(context).pushReplacementNamed(AppRouter.home);
        },
        unauthenticated: () {
          debugPrint(
            '[SplashPage] Unauthenticated during splash - redirecting to login',
          );
          Navigator.of(context).pushReplacementNamed(AppRouter.login);
        },
        error: (failure) {
          debugPrint('[SplashPage] Error during splash - redirecting to login');
          Navigator.of(context).pushReplacementNamed(AppRouter.login);
        },
      );
    },
    child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo placeholder - Replace with actual logo asset
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.kitchen,
                    size: 60.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: AppSizes.verticalSpacingXL),
                Text(
                  tr('app_name'),
                  style: TextStyle(
                    fontSize: AppSizes.textXL,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppSizes.verticalSpacingL),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.padding * 2,
                  ),
                  child: Text(
                    tr('splash_preparing'),
                    style: TextStyle(
                      fontSize: AppSizes.textM,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: AppSizes.verticalSpacingXL),
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
