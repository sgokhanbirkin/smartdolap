import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_colors.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/core/services/i_onboarding_service.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Splash screen - Shows logo and loading message
/// Automatically redirects based on auth state
class SplashPage extends StatefulWidget {
  /// Splash page constructor
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[SplashPage] Splash screen initialized');

    // Initialize opacity animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start animation
    _animationController.forward();

    // Wait 2 seconds before checking auth state
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hasNavigated) {
        _checkAuthState();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAuthState() {
    if (_hasNavigated) {
      return;
    }

    final AuthCubit authCubit = context.read<AuthCubit>();
    final AuthState currentState = authCubit.state;
    final IOnboardingService onboardingService = sl<IOnboardingService>();

    debugPrint('[SplashPage] Checking auth state: $currentState');

    // Check onboarding first
    if (!onboardingService.isOnboardingCompleted()) {
      debugPrint(
        '[SplashPage] Onboarding not completed - redirecting to onboarding',
      );
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
      return;
    }

    currentState.when(
      initial: () {
        debugPrint('[SplashPage] Initial state - waiting for auth check');
        // AuthCubit will emit authenticated/unauthenticated soon
      },
      loading: () {
        debugPrint('[SplashPage] Loading state - waiting');
      },
      authenticated: (user) {
        if (_hasNavigated) {
          return;
        }
        debugPrint('[SplashPage] Authenticated - checking household');
        _hasNavigated = true;
        if (user.householdId == null) {
          debugPrint(
            '[SplashPage] No household - redirecting to household setup (required)',
          );
          Navigator.of(context).pushReplacementNamed(AppRouter.householdSetup);
        } else {
          debugPrint('[SplashPage] Has household - redirecting to home');
          Navigator.of(context).pushReplacementNamed(AppRouter.home);
        }
      },
      unauthenticated: () {
        if (_hasNavigated) {
          return;
        }
        debugPrint('[SplashPage] Unauthenticated - redirecting to login');
        _hasNavigated = true;
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      },
      error: (failure) {
        if (_hasNavigated) {
          return;
        }
        debugPrint('[SplashPage] Error state - redirecting to login');
        _hasNavigated = true;
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
    listener: (BuildContext context, AuthState state) {
      // Only navigate if we haven't navigated yet and state is ready
      if (_hasNavigated) {
        return;
      }

      debugPrint('[SplashPage] AuthState changed: $state');
      final IOnboardingService onboardingService = sl<IOnboardingService>();

      // Check onboarding first
      if (!onboardingService.isOnboardingCompleted()) {
        debugPrint(
          '[SplashPage] Onboarding not completed - redirecting to onboarding',
        );
        _hasNavigated = true;
        Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
        return;
      }

      state.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          if (_hasNavigated) {
            return;
          }
          debugPrint(
            '[SplashPage] Authenticated during splash - checking household',
          );
          _hasNavigated = true;
          if (user.householdId == null) {
            debugPrint(
              '[SplashPage] No household - redirecting to household setup (required)',
            );
            Navigator.of(
              context,
            ).pushReplacementNamed(AppRouter.householdSetup);
          } else {
            debugPrint('[SplashPage] Has household - redirecting to home');
            Navigator.of(context).pushReplacementNamed(AppRouter.home);
          }
        },
        unauthenticated: () {
          if (_hasNavigated) {
            return;
          }
          debugPrint(
            '[SplashPage] Unauthenticated during splash - redirecting to login',
          );
          _hasNavigated = true;
          Navigator.of(context).pushReplacementNamed(AppRouter.login);
        },
        error: (failure) {
          if (_hasNavigated) {
            return;
          }
          debugPrint('[SplashPage] Error during splash - redirecting to login');
          _hasNavigated = true;
          Navigator.of(context).pushReplacementNamed(AppRouter.login);
        },
      );
    },
    child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppColors.redToBlueDark
              : AppColors.redToBlue,
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // SmartDolap Logo/Text
                  Text(
                    tr('app_name'),
                    style: TextStyle(
                      fontSize: AppSizes.textHeading,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                      letterSpacing: 1.5,
                      shadows: <Shadow>[
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                        color: AppColors.textLight.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingXL),
                  CustomLoadingIndicator(
                    size: 40.w,
                    color: AppColors.textLight,
                    type: LoadingType.pulsingGrid,
                    // Lottie animasyonu için: lottieAsset: 'assets/animations/loading.json',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
