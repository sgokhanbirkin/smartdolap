import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/firebase_options.dart';
import 'package:smartdolap/core/theme/app_theme.dart';
import 'package:smartdolap/core/theme/theme_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/services/expiry_notification_service.dart';

/// Main entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  await setupLocator();

  // Initialize notification service
  await sl<ExpiryNotificationService>().initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('tr', 'TR'), Locale('en', 'US')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr', 'TR'),
      child: const SmartDolapApp(),
    ),
  );
}

/// Main app widget
class SmartDolapApp extends StatelessWidget {
  /// SmartDolapApp constructor
  const SmartDolapApp({super.key});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(390, 844), // iPhone 12 referans
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (BuildContext context, Widget? child) => MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>(
          create: (BuildContext _) => sl<AuthCubit>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (BuildContext _) => ThemeCubit(),
        ),
      ],
      child: Builder(
        builder: (BuildContext innerContext) =>
            BlocBuilder<ThemeCubit, ThemeState>(
          builder: (BuildContext context, ThemeState themeState) =>
              BlocListener<AuthCubit, AuthState>(
            listener: (BuildContext context, AuthState authState) {
              debugPrint('[SmartDolapApp] AuthState changed: $authState');
              authState.when(
                initial: () {
                  debugPrint('[SmartDolapApp] AuthState: initial');
                },
                loading: () {
                  debugPrint('[SmartDolapApp] AuthState: loading');
                },
                authenticated: (user) {
                  debugPrint('[SmartDolapApp] AuthState: authenticated - ${user.email}');
                  // Don't navigate here, let the route guard handle it
                },
                unauthenticated: () {
                  debugPrint('[SmartDolapApp] AuthState: unauthenticated');
                  // Don't navigate here, let the route guard handle it
                },
                error: (failure) {
                  debugPrint('[SmartDolapApp] AuthState: error - $failure');
                },
              );
            },
            child: MaterialApp(
              onGenerateTitle: (BuildContext ctx) => tr('app_name'),
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeState.themeMode,
              localizationsDelegates: innerContext.localizationDelegates,
              supportedLocales: innerContext.supportedLocales,
              locale: innerContext.locale,
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: AppRouter.splash,
            ),
          ),
        ),
      ),
    ),
  );
}
