// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

class RecipeCard extends StatefulWidget {
  const RecipeCard({required this.recipe, this.onTap, super.key});

  final Recipe recipe;
  final VoidCallback? onTap;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _fav = false;

  String get _favKey =>
      widget.recipe.id.isNotEmpty ? widget.recipe.id : widget.recipe.title;

  @override
  void initState() {
    super.initState();
    _loadFav();
  }

  Future<Box<dynamic>> _favoritesBox() async {
    if (Hive.isBoxOpen('favorite_recipes')) {
      return Hive.box<dynamic>('favorite_recipes');
    }
    return Hive.openBox<dynamic>('favorite_recipes');
  }

  Future<void> _loadFav() async {
    final Box<dynamic> box = await _favoritesBox();
    if (!mounted) {
      return;
    }
    setState(() => _fav = box.containsKey(_favKey));
  }

  Future<void> _toggleFav() async {
    final Box<dynamic> box = await _favoritesBox();
    if (box.containsKey(_favKey)) {
      await box.delete(_favKey);
      if (!mounted) {
        return;
      }
      setState(() => _fav = false);
    } else {
      await box.put(_favKey, widget.recipe.toMap());
      if (!mounted) {
        return;
      }
      setState(() => _fav = true);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    ),
    child: InkWell(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.recipe.category != null)
            Padding(
              padding: EdgeInsets.only(
                left: AppSizes.cardPadding,
                right: AppSizes.cardPadding,
                top: AppSizes.cardPadding,
              ),
              child: Row(
                children: <Widget>[
                  Chip(
                    label: Text(
                      widget.recipe.category!,
                      style: TextStyle(fontSize: AppSizes.textS),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  if (widget.recipe.missingCount != null)
                    Chip(
                      backgroundColor: _badgeColor(
                        context,
                        widget.recipe.missingCount!,
                      ),
                      label: Text(
                        _badgeText(context, widget.recipe.missingCount!),
                        style: TextStyle(
                          fontSize: AppSizes.textS,
                          color: Colors.white,
                        ),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          // Image area with favorite and difficulty badge
          Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child:
                    widget.recipe.imageUrl != null &&
                        widget.recipe.imageUrl!.isNotEmpty
                    ? Image.network(
                        widget.recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, Object error, StackTrace? stackTrace) {
                          debugPrint(
                            'Resim yüklenemedi: ${widget.recipe.imageUrl} - $error',
                          );
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.restaurant_menu, size: 32.sp),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.restaurant_menu, size: 32.sp),
                      ),
              ),
              // Difficulty badge - sol üst
              if (widget.recipe.difficulty != null &&
                  widget.recipe.difficulty!.isNotEmpty)
                Positioned(
                  left: AppSizes.spacingS,
                  top: AppSizes.spacingS,
                  child: _InfoBadge(
                    icon: Icons.speed_outlined,
                    label: widget.recipe.difficulty!,
                    color: _difficultyColor(widget.recipe.difficulty!),
                  ),
                ),
              // Favorite button - sağ üst
              Positioned(
                right: AppSizes.spacingS,
                top: AppSizes.spacingS,
                child: IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  onPressed: _toggleFav,
                  icon: Icon(
                    _fav ? Icons.star : Icons.star_border,
                    color: _fav ? Colors.amber : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(AppSizes.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.recipe.title,
                  style: TextStyle(fontSize: AppSizes.text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizes.verticalSpacingS),
                Flexible(
                  child: Text(
                    widget.recipe.ingredients.take(3).join(', '),
                    style: TextStyle(
                      fontSize: AppSizes.textS,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: AppSizes.verticalSpacingS),
                // Bottom badges row: Duration (sol) ve Calories (sağ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Duration badge - sol alt
                    if (widget.recipe.durationMinutes != null)
                      Flexible(
                        child: _InfoBadge(
                          icon: Icons.timer_outlined,
                          label: tr(
                            'duration_minutes',
                            namedArgs: <String, String>{
                              'value': '${widget.recipe.durationMinutes}',
                            },
                          ),
                          color: Colors.blue,
                        ),
                      ),
                    if (widget.recipe.durationMinutes != null && 
                        widget.recipe.calories != null)
                      SizedBox(width: AppSizes.spacingXS),
                    // Calories badge - sağ alt
                    if (widget.recipe.calories != null)
                      Flexible(
                        child: _InfoBadge(
                          icon: Icons.local_fire_department_outlined,
                          label: tr(
                            'calories_kcal',
                            namedArgs: <String, String>{
                              'value': '${widget.recipe.calories}',
                            },
                          ),
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  String _badgeText(BuildContext context, int m) {
    if (m <= 0) {
      return tr('all_ingredients');
    }
    return tr('missing_n', namedArgs: <String, String>{'n': '$m'});
  }

  Color _badgeColor(BuildContext context, int m) {
    if (m <= 0) {
      return Colors.green.shade600;
    }
    if (m == 1) {
      return Colors.teal.shade600;
    }
    if (m == 2) {
      return Colors.orange.shade600;
    }
    return Colors.red.shade600;
  }

  Color _difficultyColor(String difficulty) {
    final String lower = difficulty.toLowerCase();
    if (lower.contains('kolay') || lower.contains('easy')) {
      return Colors.green.shade600;
    }
    if (lower.contains('orta') || lower.contains('medium')) {
      return Colors.orange.shade600;
    }
    if (lower.contains('zor') || lower.contains('hard')) {
      return Colors.red.shade600;
    }
    return Colors.grey.shade600;
  }
}

/// Info badge widget for recipe cards
class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.spacingS,
      vertical: AppSizes.spacingXS * 0.5,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radius),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: AppSizes.iconXS, color: color),
        SizedBox(width: AppSizes.spacingXS * 0.5),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.textXS,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
