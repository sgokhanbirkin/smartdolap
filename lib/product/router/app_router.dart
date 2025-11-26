import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/widgets/splash_page.dart';
import 'package:smartdolap/features/analytics/presentation/view/analytics_page.dart';
import 'package:smartdolap/features/auth/presentation/view/login_page.dart';
import 'package:smartdolap/features/auth/presentation/view/register_page.dart';
import 'package:smartdolap/features/food_preferences/presentation/view/food_preferences_onboarding_page.dart';
import 'package:smartdolap/features/food_preferences/presentation/viewmodel/food_preferences_cubit.dart';
import 'package:smartdolap/features/household/presentation/view/household_setup_page.dart';
import 'package:smartdolap/features/household/presentation/view/share_page.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_cubit.dart';
import 'package:smartdolap/features/onboarding/presentation/view/onboarding_page.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_notification_coordinator.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/view/add_pantry_item_page.dart';
import 'package:smartdolap/features/pantry/presentation/view/pantry_item_detail_page.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_view_model.dart';
import 'package:smartdolap/features/profile/presentation/view/badges_page.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/view/favorites_page.dart';
import 'package:smartdolap/features/recipes/presentation/view/get_suggestions_page.dart';
import 'package:smartdolap/features/recipes/presentation/view/meal_recipes_page.dart';
import 'package:smartdolap/features/recipes/presentation/view/recipe_detail_page.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/shopping/presentation/view/shopping_list_page.dart';
import 'package:smartdolap/product/widgets/app_shell.dart';

/// App router configuration
class AppRouter {
  /// Splash route path
  static const String splash = '/splash';

  /// Onboarding route path
  static const String onboarding = '/onboarding';

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

  /// Badges route path
  static const String badges = '/profile/badges';

  /// Household setup route path
  static const String householdSetup = '/household/setup';

  /// Food preferences onboarding route path
  static const String foodPreferencesOnboarding =
      '/food-preferences/onboarding';

  /// Share route path
  static const String share = '/share';

  /// Analytics route path
  static const String analytics = '/analytics';

  /// Shopping list route path
  static const String shoppingList = '/shopping-list';

  /// Generate route based on route settings
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const OnboardingPage(),
          settings: settings,
        );
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
        final Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) {
            if (args == null ||
                args['householdId'] == null ||
                args['userId'] == null) {
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
            Widget child = AddPantryItemPage(
              householdId: args['householdId'] as String,
              userId: args['userId'] as String,
              avatarId: args['avatarId'] as String?,
            );
            final bool hasPantryProvider = _hasPantryProvider(context);
            if (!hasPantryProvider) {
              child = _PantryScopedPage(
                householdId: args['householdId'] as String,
                child: child,
              );
            }
            return child;
          },
        );
      case pantryDetail:
        final Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            args['item'] == null ||
            args['householdId'] == null) {
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
          builder: (BuildContext context) {
            Widget child = PantryItemDetailPage(
              item: args['item'] as PantryItem,
              userId: args['householdId'] as String,
            );
            final bool hasPantryProvider = _hasPantryProvider(context);
            if (!hasPantryProvider) {
              child = _PantryScopedPage(
                householdId: args['householdId'] as String,
                child: child,
              );
            }
            return child;
          },
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
        if (args == null ||
            args['items'] == null ||
            args['householdId'] == null) {
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
          builder: (BuildContext context) {
            Widget child = GetSuggestionsPage(
              items: args['items'] as List<PantryItem>,
              meal: args['meal'] as String?,
              userId: args['householdId'] as String,
            );
            final bool hasRecipesCubit = _hasRecipesCubit(context);
            final bool hasPantryProvider = _hasPantryProvider(context);
            if (!hasRecipesCubit) {
              child = BlocProvider<RecipesCubit>(
                create: (_) => sl<RecipesCubit>(),
                child: child,
              );
            }
            if (!hasPantryProvider) {
              child = _PantryScopedPage(
                householdId: args['householdId'] as String,
                child: child,
              );
            }
            return child;
          },
        );
      case badges:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const BadgesPage(),
        );
      case householdSetup:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => BlocProvider<HouseholdCubit>(
            create: (BuildContext _) => sl<HouseholdCubit>(),
            child: const HouseholdSetupPage(),
          ),
        );
      case foodPreferencesOnboarding:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => BlocProvider<FoodPreferencesCubit>(
            create: (BuildContext _) => sl<FoodPreferencesCubit>(),
            child: const FoodPreferencesOnboardingPage(),
          ),
        );
      case share:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const SharePage(),
        );
      case analytics:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const AnalyticsPage(),
          settings: settings,
        );
      case shoppingList:
        return MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const ShoppingListPage(),
          settings: settings,
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
  }) => Navigator.of(context).pushNamedAndRemoveUntil(
    routeName,
    (Route<dynamic> route) => false,
    arguments: arguments,
  );

  static PantryViewModel _buildPantryViewModel(PantryCubit cubit) =>
      PantryViewModel(
        cubit: cubit,
        listPantryItems: sl<ListPantryItems>(),
        addPantryItem: sl<AddPantryItem>(),
        updatePantryItem: sl<UpdatePantryItem>(),
        deletePantryItem: sl<DeletePantryItem>(),
        notificationCoordinator: sl<IPantryNotificationCoordinator>(),
      );

  static bool _hasPantryProvider(BuildContext context) =>
      context
          .findAncestorWidgetOfExactType<
            RepositoryProvider<PantryViewModel>
          >() !=
      null;

  static bool _hasRecipesCubit(BuildContext context) =>
      context.findAncestorWidgetOfExactType<BlocProvider<RecipesCubit>>() !=
      null;
}

class _PantryScopedPage extends StatefulWidget {
  const _PantryScopedPage({required this.householdId, required this.child});

  final String householdId;
  final Widget child;

  @override
  State<_PantryScopedPage> createState() => _PantryScopedPageState();
}

class _PantryScopedPageState extends State<_PantryScopedPage> {
  late final PantryCubit _cubit = sl<PantryCubit>();
  late final PantryViewModel _viewModel = AppRouter._buildPantryViewModel(
    _cubit,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_viewModel.watch(widget.householdId));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<PantryCubit>.value(
    value: _cubit,
    child: RepositoryProvider<PantryViewModel>.value(
      value: _viewModel,
      child: widget.child,
    ),
  );
}
