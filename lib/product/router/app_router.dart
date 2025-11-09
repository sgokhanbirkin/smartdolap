import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/presentation/view/login_page.dart';
import 'package:smartdolap/features/auth/presentation/view/register_page.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/view/add_pantry_item_page.dart';
import 'package:smartdolap/features/pantry/presentation/view/pantry_item_detail_page.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/view/favorites_page.dart';
import 'package:smartdolap/features/recipes/presentation/view/get_suggestions_page.dart';
import 'package:smartdolap/features/recipes/presentation/view/meal_recipes_page.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/view/recipe_detail_page.dart';
import 'package:smartdolap/core/widgets/splash_page.dart';
import 'package:smartdolap/product/widgets/app_shell.dart';

/// App router configuration
class AppRouter {
  /// Splash route path
  static const String splash = '/splash';

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

  /// Favorites route path
  static const String favorites = '/recipes/favorites';

  /// Meal recipes route path
  static const String mealRecipes = '/recipes/meal';

  /// Get suggestions route path
  static const String getSuggestions = '/recipes/get-suggestions';

  /// Generate route based on route settings
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const SplashPage(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const LoginPage(),
          settings: settings,
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
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.padding),
                    child: Text(
                      tr('invalid_user_info'),
                      style: TextStyle(fontSize: AppSizes.text),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
        if (args == null || args['item'] == null || args['userId'] == null) {
          return MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Text(
                    tr('invalid_parameters'),
                    style: TextStyle(fontSize: AppSizes.text),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
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
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => RecipeDetailPage(recipe: recipe),
        );
      case favorites:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const FavoritesPage(),
        );
      case mealRecipes:
        final Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        if (args == null || args['meal'] == null || args['userId'] == null) {
          return MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Text(
                    tr('invalid_parameters'),
                    style: TextStyle(fontSize: AppSizes.text),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => MealRecipesPage(
            meal: args['meal'] as String,
            userId: args['userId'] as String,
          ),
        );
      case getSuggestions:
        final Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        if (args == null || args['items'] == null || args['userId'] == null) {
          return MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Text(
                    tr('invalid_parameters'),
                    style: TextStyle(fontSize: AppSizes.text),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<RecipesCubit>(
            create: (_) => sl<RecipesCubit>(),
              ),
              BlocProvider<PantryCubit>(
                create: (_) => sl<PantryCubit>()..watch(args['userId'] as String),
              ),
            ],
            child: GetSuggestionsPage(
              items: args['items'] as List<PantryItem>,
              meal: args['meal'] as String?,
              userId: args['userId'] as String,
            ),
          ),
        );
      case home:
      default:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const AppShell(),
          settings: settings,
        );
    }
  }

  /// Push named route and remove all previous routes
  static Future<void> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    debugPrint('[AppRouter] pushNamedAndRemoveUntil: $routeName');
    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }
}
