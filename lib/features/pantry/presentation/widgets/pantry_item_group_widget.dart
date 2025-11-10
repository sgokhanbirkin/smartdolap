import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/category_colors.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Widget for displaying a category group with its items
class PantryItemGroupWidget extends StatefulWidget {
  const PantryItemGroupWidget({
    required this.category,
    required this.items,
    required this.userId,
    required this.onItemTap,
    this.onQuantityChanged,
    required this.buildDismissibleCard,
    super.key,
  });

  /// Category name
  final String category;

  /// Items in this category
  final List<PantryItem> items;

  /// User ID
  final String userId;

  /// Callback when item is tapped
  final ValueChanged<PantryItem> onItemTap;

  /// Callback when item quantity changes
  final ValueChanged<PantryItem>? onQuantityChanged;

  /// Function to build dismissible card
  final Widget Function(
    BuildContext context,
    PantryItem item,
    String userId,
    VoidCallback onTap,
    int index,
  )
  buildDismissibleCard;

  @override
  State<PantryItemGroupWidget> createState() => _PantryItemGroupWidgetState();
}

class _PantryItemGroupWidgetState extends State<PantryItemGroupWidget>
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
  Widget build(BuildContext context) {
    final Color categoryColor = CategoryColors.getCategoryColor(
      widget.category,
    );
    final Color categoryIconColor = CategoryColors.getCategoryIconColor(
      widget.category,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingS,
              ),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    PantryCategoryHelper.iconFor(widget.category),
                    color: categoryIconColor,
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: Text(
                      PantryCategoryHelper.getLocalizedCategoryName(
                        widget.category,
                      ),
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        fontWeight: FontWeight.w600,
                        color: categoryIconColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingS,
                      vertical: AppSizes.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                    child: Text(
                      '${widget.items.length}',
                      style: TextStyle(
                        fontSize: AppSizes.textXS,
                        fontWeight: FontWeight.bold,
                        color: categoryIconColor,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  RotationTransition(
                    turns: Tween<double>(
                      begin: 0.0,
                      end: 0.5,
                    ).animate(_expandAnimation),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: categoryIconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: <Widget>[
                SizedBox(height: AppSizes.spacingS),
                ...widget.items.asMap().entries.map(
                  (MapEntry<int, PantryItem> entry) => Padding(
                    padding: EdgeInsets.only(bottom: AppSizes.spacingS),
                    child: widget.buildDismissibleCard(
                      context,
                      entry.value,
                      widget.userId,
                      () => widget.onItemTap(entry.value),
                      entry.key,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
