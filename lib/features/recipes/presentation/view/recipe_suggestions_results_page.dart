import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/compact_recipe_card_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Results page showing generated recipe suggestions
class RecipeSuggestionsResultsPage extends StatelessWidget {
  /// Creates a recipe suggestions results page
  const RecipeSuggestionsResultsPage({
    required this.recipes,
    this.meal,
    super.key,
  });

  /// Generated recipes
  final List<Recipe> recipes;

  /// Optional meal category
  final String? meal;

  @override
  Widget build(BuildContext context) {
    final String mealTitle = meal != null
        ? tr('meal_$meal')
        : tr('suggested_recipes');

    return BackgroundWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(mealTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil(
              (route) =>
                  route.settings.name == '/recipes' ||
                  route.settings.name == AppRouter.home ||
                  route.isFirst,
            ),
          ),
        ),
        body: recipes.isEmpty
            ? _buildEmptyState(context)
            : _buildRecipesList(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.restaurant_menu,
          size: 64.w,
          color: Theme.of(context).colorScheme.outline,
        ),
        SizedBox(height: AppSizes.verticalSpacingM),
        Text(
          tr('no_recipes_found'),
          style: TextStyle(
            fontSize: AppSizes.textL,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppSizes.verticalSpacingS),
        Text(
          tr('try_different_ingredients'),
          style: TextStyle(
            fontSize: AppSizes.textM,
            color: Theme.of(context).colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildRecipesList(BuildContext context) => Column(
    children: <Widget>[
      // Header with count
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.padding),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.restaurant,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: AppSizes.spacingS),
            Text(
              tr(
                'recipes_found_count',
                namedArgs: <String, String>{'count': recipes.length.toString()},
              ),
              style: TextStyle(
                fontSize: AppSizes.textL,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      // Recipes grid
      Expanded(
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.spacingM,
            crossAxisSpacing: AppSizes.spacingM,
            childAspectRatio: 0.75,
          ),
          itemCount: recipes.length,
          itemBuilder: (BuildContext context, int index) {
            final Recipe recipe = recipes[index];
            return CompactRecipeCardWidget(
              recipe: recipe,
              onTap: () => _openRecipeDetail(context, recipe),
            );
          },
        ),
      ),
    ],
  );

  void _openRecipeDetail(BuildContext context, Recipe recipe) {
    Navigator.of(context).pushNamed(AppRouter.recipeDetail, arguments: recipe);
  }
}
