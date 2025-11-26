import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smartdolap/core/constants/app_colors.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/category_colors.dart';
import 'package:smartdolap/core/utils/quantity_formatter.dart';
import 'package:smartdolap/core/widgets/cached_image_widget.dart';
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
    if (widget.onQuantityChanged == null || widget.userId == null) {
      return;
    }

    final String unit = widget.item.unit.toLowerCase().trim();
    double increment;
    
    // Birim bazlı artış mantığı
    if (unit == 'g' || unit == 'gr' || unit == 'gram') {
      increment = delta > 0 ? 25 : -25; // Gram için 25'er artış
    } else if (unit == 'kg' || unit == 'kilogram') {
      increment = delta > 0 ? 0.1 : -0.1; // Kg için 0.1'er artış
    } else if (unit == 'ml' || unit == 'mililitre') {
      increment = delta > 0 ? 50 : -50; // ML için 50'şer artış
    } else if (unit == 'lt' ||
        unit == 'l' ||
        unit == 'litre' ||
        unit == 'liter') {
      increment = delta > 0 ? 0.1 : -0.1; // Litre için 0.1'er artış
    } else if (unit == 'adet' ||
        unit == 'tane' ||
        unit == 'paket' ||
        unit == 'kutu' ||
        unit == 'demet') {
      increment = delta > 0 ? 1 : -1; // Adet bazlı birimler için 1'er artış
    } else {
      increment = delta > 0 ? 0.5 : -0.5; // Varsayılan
    }

    // Floating-point precision sorununu önlemek için yuvarlama
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
          child: Container(
            decoration: BoxDecoration(
              color: widget.item.category != null
                  ? CategoryColors.getCategoryColor(widget.item.category!)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isPressed
                    ? (widget.item.category != null
                        ? CategoryColors.getCategoryIconColor(
                            widget.item.category!,
                          )
                        : AppColors.primaryBlue)
                        .withValues(alpha: 0.5)
                    : Colors.transparent,
                width: _isPressed ? 2 : 0,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (widget.item.category != null
                          ? CategoryColors.getCategoryColor(
                              widget.item.category!,
                            )
                          : AppColors.surfaceLight)
                      .withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
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
                      CachedImageWidget(
                        imageUrl: _isValidUrl(widget.item.imageUrl)
                            ? widget.item.imageUrl
                            : null,
                        width: AppSizes.iconXXL,
                        height: AppSizes.iconXXL,
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        placeholderIcon: Icons.shopping_basket,
                        errorIcon: Icons.shopping_basket,
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.spacingS,
                                vertical: AppSizes.spacingXS * 0.5,
                              ),
                              decoration: BoxDecoration(
                                color: widget.item.category != null
                                    ? CategoryColors.getCategoryIconColor(
                                        widget.item.category!,
                                      ).withValues(alpha: 0.15)
                                    : AppColors.primaryBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppSizes.radius * 0.75),
                              ),
                              child: Text(
                                widget.item.name,
                                style: TextStyle(
                                  fontSize: AppSizes.text,
                                  fontWeight: FontWeight.w600,
                                  color: widget.item.category != null
                                      ? CategoryColors.getCategoryIconColor(
                                          widget.item.category!,
                                        )
                                      : AppColors.primaryBlue,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSizes.spacingXS),
                            Row(
                              children: <Widget>[
                                // Quick actions - Quantity +/- buttons
                                if (hasQuickActions) ...<Widget>[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    iconSize: AppSizes.iconS,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _handleQuantityChange(-1);
                                    },
                                    color: widget.item.category != null
                                        ? CategoryColors.getCategoryIconColor(
                                            widget.item.category!,
                                          )
                                        : AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: AppSizes.spacingXS),
                                ],
                                Text(
                                  '${QuantityFormatter.formatQuantity(
                                    widget.item.quantity,
                                    widget.item.unit,
                                  )} ${widget.item.unit}'.trim(),
                                  style: TextStyle(
                                    fontSize: AppSizes.textS,
                                    fontWeight: FontWeight.w500,
                                    color: widget.item.category != null
                                        ? CategoryColors.getCategoryIconColor(
                                            widget.item.category!,
                                          ).withValues(alpha: 0.8)
                                        : AppColors.textMedium,
                                  ),
                                ),
                                if (hasQuickActions) ...<Widget>[
                                  SizedBox(width: AppSizes.spacingXS),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    iconSize: AppSizes.iconS,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _handleQuantityChange(1),
                                    color: widget.item.category != null
                                        ? CategoryColors.getCategoryIconColor(
                                            widget.item.category!,
                                          )
                                        : AppColors.primaryBlue,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Expiry date - Color coded with contrast
                      if (widget.item.expiryDate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: expiryColor.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                size: AppSizes.iconS * 0.8,
                                color: AppColors.textLight,
                              ),
                            ),
                            SizedBox(height: AppSizes.spacingXS * 0.5),
                            Text(
                              _formatDate(widget.item.expiryDate!),
                              style: TextStyle(
                                fontSize: AppSizes.textXS,
                                fontWeight: FontWeight.w600,
                                color: widget.item.category != null
                                    ? CategoryColors.getCategoryIconColor(
                                        widget.item.category!,
                                      )
                                    : expiryColor,
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
