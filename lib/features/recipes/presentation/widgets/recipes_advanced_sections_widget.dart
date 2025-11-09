import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/constants/mvp_flags.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/utils/meal_time_order_helper.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipe_row_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Widget for displaying advanced recipe sections (favorites, meals, made recipes)
class RecipesAdvancedSectionsWidget extends StatelessWidget {
  /// Creates an advanced sections widget
  const RecipesAdvancedSectionsWidget({
    required this.favorites,
    required this.breakfastRecipes,
    required this.snackRecipes,
    required this.lunchRecipes,
    required this.dinnerRecipes,
    required this.madeRecipes,
    required this.loadingStates,
    required this.onRecipeTap,
    required this.activeUserId,
    super.key,
  });

  /// Favorite recipes
  final List<Recipe> favorites;

  /// Breakfast recipes
  final List<Recipe> breakfastRecipes;

  /// Snack recipes
  final List<Recipe> snackRecipes;

  /// Lunch recipes
  final List<Recipe> lunchRecipes;

  /// Dinner recipes
  final List<Recipe> dinnerRecipes;

  /// Made recipes
  final List<Recipe> madeRecipes;

  /// Loading states for each section
  final Map<String, bool> loadingStates;

  /// Callback when recipe is tapped
  final ValueChanged<Recipe> onRecipeTap;

  /// Active user ID for navigation
  final String? activeUserId;

  @override
  Widget build(BuildContext context) {
    if (!kEnableAdvancedRecipeSections) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Favorites row
          RecipeRowWidget(
            title: tr('recipes_favorites_title'),
            recipes: favorites,
            backgroundColor: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3),
            icon: Icons.favorite,
            isLoading: loadingStates['favorites'] ?? false,
            onRecipeTap: onRecipeTap,
            onViewAll: () => Navigator.of(context).pushNamed(AppRouter.favorites),
          ),
          // Meal rows
          ..._buildMealRows(context),
          // Made recipes row
          RecipeRowWidget(
            title: tr('made_recipes'),
            recipes: madeRecipes,
            backgroundColor: Theme.of(context)
                .colorScheme
                .tertiaryContainer
                .withValues(alpha: 0.3),
            icon: Icons.check_circle_outline,
            isLoading: loadingStates['made'] ?? false,
            onRecipeTap: onRecipeTap,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMealRows(BuildContext context) {
    final List<String> orderedMeals = MealTimeOrderHelper.getOrderedMeals();
    final List<Widget> rows = <Widget>[];

    for (final String meal in orderedMeals) {
      List<Recipe> recipes;
      switch (meal) {
        case 'breakfast':
          recipes = breakfastRecipes;
          break;
        case 'snack':
          recipes = snackRecipes;
          break;
        case 'lunch':
          recipes = lunchRecipes;
          break;
        case 'dinner':
          recipes = dinnerRecipes;
          break;
        default:
          recipes = <Recipe>[];
      }

      rows.add(
        RecipeRowWidget(
          title:
              '${tr('you_can_make')} - ${MealTimeOrderHelper.getMealName(meal)}',
          recipes: recipes,
          backgroundColor: MealTimeOrderHelper.getMealColor(meal),
          icon: MealTimeOrderHelper.getMealIcon(meal),
          isLoading: loadingStates[meal] ?? false,
          onRecipeTap: onRecipeTap,
          onViewAll: activeUserId != null
              ? () => Navigator.of(context).pushNamed(
                    '/recipes/meal',
                    arguments: <String, dynamic>{
                      'meal': meal,
                      'userId': activeUserId!,
                    },
                  )
              : null,
        ),
      );
    }

    return rows;
  }
}

