import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/compact_recipe_card_widget.dart';

/// Widget for displaying search results
class RecipesSearchResultsWidget extends StatelessWidget {
  /// Creates a recipes search results widget
  const RecipesSearchResultsWidget({
    required this.recipes,
    required this.onRecipeTap,
    required this.scrollController,
    super.key,
  });

  /// List of filtered recipes
  final List<Recipe> recipes;

  /// Callback when recipe is tapped
  final ValueChanged<Recipe> onRecipeTap;

  /// Scroll controller for the grid
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search_off,
              size: AppSizes.iconXXL * 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
            Text(
              tr('no_items_found'),
              style: TextStyle(
                fontSize: AppSizes.textM,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(AppSizes.padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveGrid.getCrossAxisCount(context),
        crossAxisSpacing: AppSizes.spacingS,
        mainAxisSpacing: AppSizes.spacingS,
        childAspectRatio: ResponsiveGrid.getChildAspectRatio(context),
      ),
      itemCount: recipes.length,
      itemBuilder: (BuildContext context, int index) {
        final Recipe recipe = recipes[index];
        return RepaintBoundary(
          child: CompactRecipeCardWidget(
            recipe: recipe,
            onTap: () => onRecipeTap(recipe),
          ),
        );
      },
    );
  }
}
