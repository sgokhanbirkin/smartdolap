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

  Future<void> _loadFav() async {
    final Box<String> box = Hive.isBoxOpen('favorites')
        ? Hive.box<String>('favorites')
        : await Hive.openBox<String>('favorites');
    setState(() => _fav = box.containsKey(_favKey));
  }

  Future<void> _toggleFav() async {
    final Box<String> box = Hive.isBoxOpen('favorites')
        ? Hive.box<String>('favorites')
        : await Hive.openBox<String>('favorites');
    if (box.containsKey(_favKey)) {
      await box.delete(_favKey);
      setState(() => _fav = false);
    } else {
      await box.put(_favKey, widget.recipe.title);
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
          // Image area with favorite
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
                        errorBuilder: (_, __, ___) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.restaurant_menu, size: 32.sp),
                        ),
                      )
                    : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.restaurant_menu, size: 32.sp),
                      ),
              ),
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
              children: <Widget>[
                Text(
                  widget.recipe.title,
                  style: TextStyle(fontSize: AppSizes.text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizes.verticalSpacingS),
                Text(
                  widget.recipe.ingredients.take(3).join(', '),
                  style: TextStyle(fontSize: AppSizes.textS),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
}
