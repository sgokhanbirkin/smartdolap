import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/animated_badge.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/compact_recipe_card_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Favorites shelf widget with collapse/expand functionality
class FavoritesShelfWidget extends StatefulWidget {
  const FavoritesShelfWidget({
    required this.favoritesFuture,
    this.onRecipeTap,
    super.key,
  });

  final Future<Box<dynamic>> favoritesFuture;
  final ValueChanged<Recipe>? onRecipeTap;

  @override
  State<FavoritesShelfWidget> createState() => _FavoritesShelfWidgetState();
}

class _FavoritesShelfWidgetState extends State<FavoritesShelfWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.value = 1.0; // Başlangıçta açık
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Box<dynamic>>(
    future: widget.favoritesFuture,
    builder: (BuildContext context, AsyncSnapshot<Box<dynamic>> snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox.shrink();
      }
      final Box<dynamic> favoritesBox = snapshot.data!;
      final List<Recipe> favorites = favoritesBox.values
          .whereType<Map<dynamic, dynamic>>()
          .map<Recipe>(Recipe.fromMap)
          .toList();

      if (favorites.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingM),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.padding),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.favorite_border,
                    size: AppSizes.icon,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Text(
                      tr('no_favorites_message'),
                      style: TextStyle(
                        fontSize: AppSizes.textS,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return ValueListenableBuilder<Box<dynamic>>(
        valueListenable: favoritesBox.listenable(),
        builder: (BuildContext context, Box<dynamic> box, Widget? child) {
          final List<Recipe> updatedFavorites = box.values
              .whereType<Map<dynamic, dynamic>>()
              .map<Recipe>(Recipe.fromMap)
              .toList();

          if (updatedFavorites.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingM),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.favorite_border,
                        size: AppSizes.icon,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: Text(
                          tr('no_favorites_message'),
                          style: TextStyle(
                            fontSize: AppSizes.textS,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Başlık - tıklanabilir ve belirgin
              InkWell(
                onTap: _toggleExpansion,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingM,
                    vertical: AppSizes.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.favorite,
                        size: AppSizes.iconS,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      Flexible(
                        child: Text(
                          tr('recipes_favorites_title'),
                          style: TextStyle(
                            fontSize: AppSizes.textM,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      AnimatedBadge(
                        label: tr(
                          'favorites_count',
                          namedArgs: <String, String>{
                            'count': '${updatedFavorites.length}',
                          },
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        textColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        delay: 100,
                      ),
                      const Spacer(),
                      // Tümünü Gör butonu - InkWell'in tıklamasını
                      // engellemek için GestureDetector
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRouter.favorites);
                        },
                        child: TextButton.icon(
                          // null yaparak InkWell'in tıklamasını engelle
                          onPressed: null,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: AppSizes.iconXS,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            tr('view_all_favorites'),
                            style: TextStyle(
                              fontSize: AppSizes.textS,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingXS),
                      RotationTransition(
                        turns: Tween<double>(begin: 0.0, end: 0.5)
                            .animate(_expandAnimation),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.primary,
                          size: AppSizes.icon,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Kapandığında gösterilecek hint text
              if (!_isExpanded)
                Padding(
                  padding: EdgeInsets.only(
                    top: AppSizes.spacingXS,
                    left: AppSizes.spacingM,
                  ),
                  child: Text(
                    tr('tap_to_expand'),
                    style: TextStyle(
                      fontSize: AppSizes.textXS,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              // Kartlar - SizeTransition ile animasyonlu açılma/kapanma
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: SizedBox(
                  height: AppSizes.verticalSpacingXXL * 7.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: updatedFavorites.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: AppSizes.spacingS),
                    itemBuilder: (BuildContext context, int index) {
                      final Recipe recipe = updatedFavorites[index];
                      return SizedBox(
                        width: AppSizes.spacingXXL * 5,
                        height: AppSizes.verticalSpacingXXL * 7.0,
                        child: CompactRecipeCardWidget(
                          recipe: recipe,
                          onTap: () => widget.onRecipeTap?.call(recipe),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
            ],
          );
        },
      );
    },
  );
}
