import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/animated_badge.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/compact_recipe_card_widget.dart';

/// Recipe row widget - displays recipes in a horizontal scrollable row
class RecipeRowWidget extends StatelessWidget {
  const RecipeRowWidget({
    required this.title,
    required this.recipes,
    required this.backgroundColor,
    required this.icon,
    required this.onRecipeTap,
    this.onViewAll,
    this.isLoading = false,
    super.key,
  });

  final String title;
  final List<Recipe> recipes;
  final Color backgroundColor;
  final IconData icon;
  final ValueChanged<Recipe> onRecipeTap;
  final VoidCallback? onViewAll;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.verticalSpacingM),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Başlık
          Padding(
            padding: EdgeInsets.all(AppSizes.spacingM),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: AppSizes.iconS,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(width: AppSizes.spacingS),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: AppSizes.textM,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSizes.spacingS),
                if (recipes.isNotEmpty)
                  AnimatedBadge(
                    label: '${recipes.length}',
                    backgroundColor: backgroundColor.withValues(alpha: 0.5),
                    textColor: Theme.of(context).colorScheme.onSurface,
                    delay: 100,
                  ),
                if (onViewAll != null && recipes.isNotEmpty) ...[
                  SizedBox(width: AppSizes.spacingS),
                  TextButton.icon(
                    onPressed: onViewAll,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: AppSizes.iconXS,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    label: Text(
                      tr('view_all'),
                      style: TextStyle(
                        fontSize: AppSizes.textS,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // İçerik: Horizontal Scroll ListView, Loading veya Empty State
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(AppSizes.spacingL),
              child: Center(
                child: CustomLoadingIndicator(
                  size: 40,
                  type: LoadingType.pulsingGrid,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else if (recipes.isEmpty)
            Padding(
              padding: EdgeInsets.all(AppSizes.spacingL),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Icon(
                      icon,
                      size: AppSizes.iconXL,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: AppSizes.spacingM),
                    Text(
                      tr('no_recipes_yet'),
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200, // Kart yüksekliği
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
                itemCount: recipes.length,
                itemBuilder: (BuildContext context, int index) {
                  final Recipe recipe = recipes[index];
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    margin: EdgeInsets.only(right: AppSizes.spacingS),
                    child: CompactRecipeCardWidget(
                      recipe: recipe,
                      onTap: () => onRecipeTap(recipe),
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: AppSizes.verticalSpacingM),
        ],
      ),
    );
  }
}

