import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/avatar_widget.dart';
import 'package:smartdolap/features/household/domain/entities/shared_recipe.dart';
import 'package:smartdolap/features/recipes/presentation/view/recipe_detail_page.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Shared recipes tab page - Shows shared recipes grid
class SharedRecipesTabPage extends StatelessWidget {
  /// Shared recipes tab page constructor
  const SharedRecipesTabPage({required this.sharedRecipes, super.key});

  final List<SharedRecipe> sharedRecipes;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: sharedRecipes.isEmpty
          ? Center(
              child: Text(
                tr('no_shared_recipes'),
                style: TextStyle(
                  fontSize: AppSizes.textM,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(AppSizes.padding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.75,
              ),
              itemCount: sharedRecipes.length,
              itemBuilder: (BuildContext context, int index) {
                final SharedRecipe sharedRecipe = sharedRecipes[index];
                return _buildSharedRecipeCard(context, sharedRecipe);
              },
            ),
    );
  }

  Widget _buildSharedRecipeCard(
    BuildContext context,
    SharedRecipe sharedRecipe,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: InkWell(
        onTap: () {
          // Convert SharedRecipe to Recipe for detail page
          final Recipe recipe = Recipe(
            id: sharedRecipe.recipe.id,
            title: sharedRecipe.recipe.title,
            ingredients: sharedRecipe.recipe.ingredients,
            steps: sharedRecipe.recipe.steps,
            calories: null,
            durationMinutes: null,
            difficulty: null,
            imageUrl: sharedRecipe.recipe.imagePath,
            category: sharedRecipe.recipe.tags.isNotEmpty
                ? sharedRecipe.recipe.tags.first
                : null,
            missingCount: 0,
            fiber: null,
          );

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => RecipeDetailPage(
                recipe: recipe,
                isHouseholdOnly: true,
                householdId: sharedRecipe.householdId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Recipe image placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radius),
                    topRight: Radius.circular(AppSizes.radius),
                  ),
                ),
                child: sharedRecipe.recipe.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.radius),
                          topRight: Radius.circular(AppSizes.radius),
                        ),
                        child: Image.network(
                          sharedRecipe.recipe.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(context),
                        ),
                      )
                    : _buildImagePlaceholder(context),
              ),
            ),
            // Recipe info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      sharedRecipe.recipe.title,
                      style: TextStyle(
                        fontSize: AppSizes.textS,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: <Widget>[
                        AvatarWidget(
                          avatarId: sharedRecipe.avatarId,
                          size: 16.w,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            sharedRecipe.sharedByName,
                            style: TextStyle(
                              fontSize: AppSizes.textXS,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.restaurant_menu,
        size: 40.sp,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
