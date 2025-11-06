import 'package:flutter/material.dart';
import 'package:smartdolap/features/auth/presentation/view/login_page.dart';
import 'package:smartdolap/features/auth/presentation/view/register_page.dart';
import 'package:smartdolap/product/widgets/app_shell.dart';

/// App router configuration
class AppRouter {
  /// Login route path
  static const String login = '/login';

  /// Home route path
  static const String home = '/';

  /// Register route path
  static const String register = '/register';

  /// Pantry add item route path
  static const String pantryAdd = '/pantry/add';

  /// Generate route based on route settings
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const LoginPage(),
        );
      case register:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const RegisterPage(),
        );
      case home:
      default:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const AppShell(),
        );
    }
  }
}
