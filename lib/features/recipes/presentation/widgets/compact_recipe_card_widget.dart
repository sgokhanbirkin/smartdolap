import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Compact recipe card widget for favorites shelf
class CompactRecipeCardWidget extends StatefulWidget {
  const CompactRecipeCardWidget({required this.recipe, this.onTap, super.key});

  final Recipe recipe;
  final VoidCallback? onTap;

  @override
  State<CompactRecipeCardWidget> createState() =>
      _CompactRecipeCardWidgetState();
}

class _CompactRecipeCardWidgetState extends State<CompactRecipeCardWidget> {
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
    if (mounted) {
      setState(() => _fav = box.containsKey(_favKey));
    }
  }

  Future<void> _toggleFav() async {
    final Box<dynamic> box = await _favoritesBox();
    if (box.containsKey(_favKey)) {
      await box.delete(_favKey);
      if (mounted) {
        setState(() => _fav = false);
      }
    } else {
      await box.put(_favKey, widget.recipe.toMap());
      if (mounted) {
        setState(() => _fav = true);
      }
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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Category chip
          if (widget.recipe.category != null)
            Padding(
              padding: EdgeInsets.only(
                left: AppSizes.spacingS,
                right: AppSizes.spacingS,
                top: AppSizes.spacingS,
              ),
              child: Chip(
                label: Text(
                  widget.recipe.category!,
                  style: TextStyle(fontSize: AppSizes.textXS),
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),
          // Image area with favorite - Expanded ile düzgün height
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (widget.recipe.imageUrl != null &&
                    widget.recipe.imageUrl!.isNotEmpty)
                  Image.network(
                    widget.recipe.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      _,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      debugPrint(
                        'Resim yüklenemedi: '
                        '${widget.recipe.imageUrl} - $error',
                      );
                      return Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.restaurant_menu,
                          size: AppSizes.icon,
                        ),
                      );
                    },
                  ),
                if (widget.recipe.imageUrl == null ||
                    widget.recipe.imageUrl!.isEmpty)
                  Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.restaurant_menu,
                      size: AppSizes.icon,
                    ),
                  ),
                Positioned(
                  right: AppSizes.spacingXS,
                  top: AppSizes.spacingXS,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                      minimumSize: Size(
                        AppSizes.iconS * 1.4,
                        AppSizes.iconS * 1.4,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _toggleFav,
                    icon: Icon(
                      _fav ? Icons.star : Icons.star_border,
                      size: AppSizes.iconXS,
                      color: _fav ? Colors.amber : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Title and ingredients - Fixed padding
          Padding(
            padding: EdgeInsets.all(AppSizes.spacingS),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.recipe.title,
                  style: TextStyle(
                    fontSize: AppSizes.textS,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizes.spacingXS * 0.5),
                Text(
                  widget.recipe.ingredients.take(2).join(', '),
                  style: TextStyle(
                    fontSize: AppSizes.textXS,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
