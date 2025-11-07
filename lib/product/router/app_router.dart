import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/presentation/view/login_page.dart';
import 'package:smartdolap/features/auth/presentation/view/register_page.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/view/add_pantry_item_page.dart';
import 'package:smartdolap/features/pantry/presentation/view/pantry_item_detail_page.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/view/recipe_detail_page.dart';
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

  /// Pantry item detail route path
  static const String pantryDetail = '/pantry/detail';

  /// Recipe detail route path
  static const String recipeDetail = '/recipes/detail';

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
      case pantryAdd:
        final String? userId = settings.arguments as String?;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) {
            if (userId == null || userId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('User bilgisi eksik')),
              );
            }
            return BlocProvider<PantryCubit>(
              create: (_) => sl<PantryCubit>()..watch(userId),
              child: AddPantryItemPage(userId: userId),
            );
          },
        );
      case pantryDetail:
        final Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            args['item'] == null ||
            args['userId'] == null) {
          return MaterialPageRoute<dynamic>(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Geçersiz parametreler')),
            ),
          );
        }
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => BlocProvider<PantryCubit>(
            create: (_) => sl<PantryCubit>()..watch(args['userId'] as String),
            child: PantryItemDetailPage(
              item: args['item'] as PantryItem,
              userId: args['userId'] as String,
            ),
          ),
        );
      case recipeDetail:
        final Recipe? recipe = settings.arguments as Recipe?;
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => RecipeDetailPage(recipe: recipe),
        );
      case home:
      default:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const AppShell(),
        );
    }
  }
}
