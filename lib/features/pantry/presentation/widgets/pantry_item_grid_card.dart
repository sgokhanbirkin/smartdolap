import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_colors.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/category_colors.dart';
import 'package:smartdolap/core/utils/quantity_formatter.dart';
import 'package:smartdolap/core/widgets/avatar_widget.dart';
import 'package:smartdolap/core/widgets/cached_image_widget.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Compact grid card for pantry items
class PantryItemGridCard extends StatefulWidget {
  const PantryItemGridCard({
    required this.item,
    this.onTap,
    this.onQuantityChanged,
    this.userId,
    super.key,
  });

  final PantryItem item;
  final VoidCallback? onTap;
  final ValueChanged<PantryItem>? onQuantityChanged;
  final String? userId;

  @override
  State<PantryItemGridCard> createState() => _PantryItemGridCardState();
}

class _PantryItemGridCardState extends State<PantryItemGridCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final DateTime now = DateTime.now();
    final Duration difference = expiryDate.difference(now);
    final int daysUntilExpiry = difference.inDays;

    if (daysUntilExpiry < 0) {
      return Colors.red.shade700;
    } else if (daysUntilExpiry == 0) {
      return Colors.orange.shade700;
    } else if (daysUntilExpiry <= 3) {
      return Colors.orange.shade600;
    } else if (daysUntilExpiry <= 7) {
      return Colors.amber.shade700;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  void _handleQuantityChange(double delta) {
    if (widget.onQuantityChanged == null || widget.userId == null) {
      return;
    }

    final String unit = widget.item.unit.toLowerCase().trim();
    double increment;
    
    if (unit == 'g' || unit == 'gr' || unit == 'gram') {
      increment = delta > 0 ? 25 : -25;
    } else if (unit == 'kg' || unit == 'kilogram') {
      increment = delta > 0 ? 0.1 : -0.1;
    } else if (unit == 'ml' || unit == 'mililitre') {
      increment = delta > 0 ? 50 : -50;
    } else if (unit == 'lt' || unit == 'l' || unit == 'litre' || unit == 'liter') {
      increment = delta > 0 ? 0.1 : -0.1;
    } else if (unit == 'adet' ||
        unit == 'tane' ||
        unit == 'paket' ||
        unit == 'kutu' ||
        unit == 'demet') {
      increment = delta > 0 ? 1 : -1;
    } else {
      increment = delta > 0 ? 0.5 : -0.5;
    }

    double newQuantity =
        (widget.item.quantity + increment).clamp(0.1, 1000);
    newQuantity =
        QuantityFormatter.roundQuantity(newQuantity, widget.item.unit);
    
    if ((newQuantity - widget.item.quantity).abs() < 0.001) {
      return;
    }

    HapticFeedback.selectionClick();
    widget.onQuantityChanged!(widget.item.copyWith(quantity: newQuantity));
  }

  @override
  Widget build(BuildContext context) {
    final bool hasQuickActions = widget.onQuantityChanged != null;
    final Color categoryColor = widget.item.category != null
        ? CategoryColors.getCategoryColor(widget.item.category!)
        : AppColors.surfaceLight;
    final Color categoryIconColor = widget.item.category != null
        ? CategoryColors.getCategoryIconColor(widget.item.category!)
        : AppColors.primaryBlue;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(
              color: _isPressed
                  ? categoryIconColor.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: _isPressed ? 2 : 0,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.spacingXS * 0.5,
              vertical: AppSizes.spacingXS * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Icon/Image at top
                CachedImageWidget(
                  imageUrl: _isValidUrl(widget.item.imageUrl)
                      ? widget.item.imageUrl
                      : null,
                  width: 32.w,
                  height: 32.w,
                  borderRadius: BorderRadius.circular(AppSizes.radius * 0.5),
                  placeholderIcon: Icons.shopping_basket,
                  errorIcon: Icons.shopping_basket,
                ),
                SizedBox(height: AppSizes.spacingXS * 0.3),
                // Product name
                Flexible(
                  child: Text(
                    widget.item.name,
                    style: TextStyle(
                      fontSize: AppSizes.textXS * 0.9,
                      fontWeight: FontWeight.w600,
                      color: categoryIconColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: AppSizes.spacingXS * 0.2),
                // Quantity controls - more compact
                if (hasQuickActions)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _handleQuantityChange(-1),
                        child: Icon(
                          Icons.remove_circle_outline,
                          size: AppSizes.iconXS * 0.8,
                          color: categoryIconColor,
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingXS * 0.2),
                      Flexible(
                        child: Text(
                          '${QuantityFormatter.formatQuantity(
                            widget.item.quantity,
                            widget.item.unit,
                          )} ${widget.item.unit}'.trim(),
                          style: TextStyle(
                            fontSize: AppSizes.textXS * 0.75,
                            fontWeight: FontWeight.w500,
                            color: categoryIconColor.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingXS * 0.2),
                      GestureDetector(
                        onTap: () => _handleQuantityChange(1),
                        child: Icon(
                          Icons.add_circle_outline,
                          size: AppSizes.iconXS * 0.8,
                          color: categoryIconColor,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '${QuantityFormatter.formatQuantity(
                      widget.item.quantity,
                      widget.item.unit,
                    )} ${widget.item.unit}'.trim(),
                    style: TextStyle(
                      fontSize: AppSizes.textXS * 0.75,
                      fontWeight: FontWeight.w500,
                      color: categoryIconColor.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                // Avatar and expiry date row
                SizedBox(height: AppSizes.spacingXS * 0.2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Avatar
                    if (widget.item.addedByAvatarId != null)
                      Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: AvatarWidget(
                          avatarId: widget.item.addedByAvatarId,
                          size: 12.w,
                        ),
                      ),
                    // Expiry date if exists
                    if (widget.item.expiryDate != null) ...<Widget>[
                      Icon(
                        Icons.calendar_today,
                        size: AppSizes.iconXS * 0.6,
                        color: _getExpiryColor(widget.item.expiryDate!),
                      ),
                      SizedBox(width: AppSizes.spacingXS * 0.2),
                      Flexible(
                        child: Text(
                          _formatDate(widget.item.expiryDate!),
                          style: TextStyle(
                            fontSize: AppSizes.textXS * 0.7,
                            fontWeight: FontWeight.w600,
                            color: _getExpiryColor(widget.item.expiryDate!),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    if (!url.startsWith('http')) {
      return false;
    }
    if (url.contains('example.com')) {
      return false;
    }
    return true;
  }
}

