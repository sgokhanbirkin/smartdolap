import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/category_colors.dart';
import 'package:smartdolap/core/utils/quantity_formatter.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

class PantryItemCard extends StatefulWidget {
  const PantryItemCard({
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
  State<PantryItemCard> createState() => _PantryItemCardState();
}

class _PantryItemCardState extends State<PantryItemCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
      return Colors.red.shade700; // Expired
    } else if (daysUntilExpiry == 0) {
      return Colors.orange.shade700; // Today
    } else if (daysUntilExpiry <= 3) {
      return Colors.orange.shade600; // Within 3 days
    } else if (daysUntilExpiry <= 7) {
      return Colors.amber.shade700; // Within a week
    }
    return Theme.of(context).colorScheme.onSurfaceVariant; // Normal
  }

  void _handleQuantityChange(double delta) {
    if (widget.onQuantityChanged == null || widget.userId == null) return;

    final String unit = widget.item.unit.toLowerCase().trim();
    double increment;
    
    // Birim bazlı artış mantığı
    if (unit == 'g' || unit == 'gr' || unit == 'gram') {
      increment = delta > 0 ? 25 : -25; // Gram için 25'er artış
    } else if (unit == 'kg' || unit == 'kilogram') {
      increment = delta > 0 ? 0.1 : -0.1; // Kg için 0.1'er artış
    } else if (unit == 'ml' || unit == 'mililitre') {
      increment = delta > 0 ? 50 : -50; // ML için 50'şer artış
    } else if (unit == 'lt' || unit == 'l' || unit == 'litre' || unit == 'liter') {
      increment = delta > 0 ? 0.1 : -0.1; // Litre için 0.1'er artış
    } else if (unit == 'adet' || unit == 'tane' || unit == 'paket' || unit == 'kutu' || unit == 'demet') {
      increment = delta > 0 ? 1 : -1; // Adet bazlı birimler için 1'er artış
    } else {
      increment = delta > 0 ? 0.5 : -0.5; // Varsayılan
    }

    // Floating-point precision sorununu önlemek için yuvarlama
    double newQuantity = (widget.item.quantity + increment).clamp(0.1, 1000);
    newQuantity = QuantityFormatter.roundQuantity(newQuantity, widget.item.unit);
    
    if ((newQuantity - widget.item.quantity).abs() < 0.001) return;

    HapticFeedback.selectionClick();
    widget.onQuantityChanged!(widget.item.copyWith(quantity: newQuantity));
  }

  @override
  Widget build(BuildContext context) {
    final bool hasQuickActions = widget.onQuantityChanged != null;
    final Color expiryColor = widget.item.expiryDate != null
        ? _getExpiryColor(widget.item.expiryDate!)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      builder: (BuildContext context, double scale, Widget? child) =>
          Transform.scale(scale: scale, child: child),
      child: GestureDetector(
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
          child: Card(
            elevation: _isPressed ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius * 1.1),
              side: BorderSide(
                color: _isPressed
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3)
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
                width: _isPressed ? 2 : 1,
              ),
            ),
            color: widget.item.category != null
                ? CategoryColors.getCategoryColor(widget.item.category!)
                : Theme.of(context).colorScheme.surface,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.cardPadding,
                    vertical: AppSizes.cardPadding * 0.5,
                  ),
                  child: Row(
                    children: <Widget>[
                      // Image / Icon
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        child: _isValidUrl(widget.item.imageUrl)
                            ? Image.network(
                                widget.item.imageUrl!,
                                width: AppSizes.iconXXL,
                                height: AppSizes.iconXXL,
                                fit: BoxFit.cover,
                                errorBuilder: (_, Object error, StackTrace? stackTrace) {
                                  debugPrint(
                                    'Resim yüklenemedi: ${widget.item.imageUrl} - $error',
                                  );
                                  return _fallbackIcon(context);
                                },
                              )
                            : _fallbackIcon(context),
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.item.name,
                              style: TextStyle(
                                fontSize: AppSizes.text,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: AppSizes.spacingXS),
                            Row(
                              children: <Widget>[
                                // Quick actions - Quantity +/- buttons
                                if (hasQuickActions) ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    iconSize: AppSizes.iconS,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () =>
                                        _handleQuantityChange(-1),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  SizedBox(width: AppSizes.spacingXS),
                                ],
                                Text(
                                  '${QuantityFormatter.formatQuantity(widget.item.quantity, widget.item.unit)} ${widget.item.unit}'
                                      .trim(),
                                  style: TextStyle(
                                    fontSize: AppSizes.textS,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (hasQuickActions) ...[
                                  SizedBox(width: AppSizes.spacingXS),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    iconSize: AppSizes.iconS,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _handleQuantityChange(1),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Expiry date - Color coded
                      if (widget.item.expiryDate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              size: AppSizes.iconS,
                              color: expiryColor,
                            ),
                            SizedBox(height: AppSizes.spacingXS * 0.5),
                            Text(
                              _formatDate(widget.item.expiryDate!),
                              style: TextStyle(
                                fontSize: AppSizes.textXS,
                                fontWeight: FontWeight.w600,
                                color: expiryColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Category badge - Top right
                if (widget.item.category != null)
                  Positioned(
                    top: AppSizes.spacingXS,
                    right: AppSizes.spacingXS,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingS,
                        vertical: AppSizes.spacingXS * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: CategoryColors.getCategoryBadgeColor(
                          widget.item.category!,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: AppSizes.spacingXS,
                            offset: Offset(0, 1.h),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.item.category!,
                        style: TextStyle(
                          fontSize: AppSizes.textXS,
                          fontWeight: FontWeight.w600,
                          color: CategoryColors.getCategoryBadgeTextColor(
                            widget.item.category!,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  Widget _fallbackIcon(BuildContext context) => Container(
    width: AppSizes.iconXXL,
    height: AppSizes.iconXXL,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(AppSizes.radius),
    ),
    child: Icon(
      Icons.shopping_basket_outlined,
      size: AppSizes.icon,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  );

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
