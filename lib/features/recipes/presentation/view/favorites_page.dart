import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/compact_recipe_card_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';

/// Favorites page - Shows all favorite recipes
class FavoritesPage extends StatelessWidget {
  /// Favorites page constructor
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: const Color(0xFFE91E63), // Pembe/kırmızı (kalp rengi)
      foregroundColor: Colors.white,
      title: Row(
        children: <Widget>[
          Icon(Icons.favorite, size: AppSizes.icon),
          SizedBox(width: AppSizes.spacingS),
          Flexible(
            child: Text(
              tr('recipes_favorites_title'),
              style: TextStyle(
                fontSize: AppSizes.textM,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
    body: Stack(
      children: <Widget>[
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Content
              Expanded(
                child: FutureBuilder<Box<dynamic>>(
                  future: Hive.isBoxOpen('favorite_recipes')
                      ? Future<Box<dynamic>>.value(
                          Hive.box<dynamic>('favorite_recipes'),
                        )
                      : Hive.openBox<dynamic>('favorite_recipes'),
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<Box<dynamic>> snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final Box<dynamic> favoritesBox = snapshot.data!;
                        return ValueListenableBuilder<Box<dynamic>>(
                          valueListenable: favoritesBox.listenable(),
                          builder:
                              (
                                BuildContext context,
                                Box<dynamic> box,
                                Widget? child,
                              ) {
                                final List<Recipe> favorites = box.values
                                    .map<Recipe>(
                                      (dynamic value) => Recipe.fromMap(
                                        value as Map<dynamic, dynamic>,
                                      ),
                                    )
                                    .toList();

                                if (favorites.isEmpty) {
                                  return const EmptyState(
                                    messageKey: 'no_favorites_message',
                                    lottieUrl:
                                        'https://assets2.lottiefiles.com/packages/lf20_Stt1R2.json',
                                  );
                                }

                                return Padding(
                                  padding: EdgeInsets.all(AppSizes.padding),
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              ResponsiveGrid.getCrossAxisCount(
                                                context,
                                              ),
                                          crossAxisSpacing: AppSizes.spacingS,
                                          mainAxisSpacing:
                                              AppSizes.verticalSpacingS,
                                          childAspectRatio:
                                              ResponsiveGrid.getChildAspectRatio(
                                                context,
                                              ),
                                        ),
                                    itemCount: favorites.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final Recipe recipe =
                                              favorites[index];
                                          return CompactRecipeCardWidget(
                                            recipe: recipe,
                                            onTap: () =>
                                                Navigator.of(context).pushNamed(
                                                  AppRouter.recipeDetail,
                                                  arguments: recipe,
                                                ),
                                          );
                                        },
                                  ),
                                );
                              },
                        );
                      },
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
