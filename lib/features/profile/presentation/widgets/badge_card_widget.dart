import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart' as domain;

/// Badge card widget for displaying a single badge
class BadgeCardWidget extends StatefulWidget {
  /// Creates a badge card with optional animation index
  const BadgeCardWidget({
    required this.badge,
    this.onTap,
    this.index = 0,
    super.key,
  });

  /// Badge to display
  final domain.Badge badge;

  /// Optional tap callback
  final VoidCallback? onTap;

  /// Animation index for staggered animations
  final int index;

  @override
  State<BadgeCardWidget> createState() => _BadgeCardWidgetState();
}

class _BadgeCardWidgetState extends State<BadgeCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 0.5,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: GestureDetector(
          onTapDown: widget.onTap != null ? _handleTapDown : null,
          onTapUp: widget.onTap != null ? _handleTapUp : null,
          onTapCancel: widget.onTap != null ? _handleTapCancel : null,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.cardPadding * 0.75),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Icon with blur effect if locked
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(
                        _getIconData(widget.badge.icon),
                        size: AppSizes.iconXL,
                        color: widget.badge.isUnlocked
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      if (!widget.badge.isUnlocked)
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.5),
                            BlendMode.srcATop,
                          ),
                          child: Icon(
                            Icons.lock,
                            size: AppSizes.iconS,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSizes.verticalSpacingS),
                  // Badge name - Flexible to prevent overflow
                  Flexible(
                    child: Text(
                      tr(widget.badge.nameKey),
                      style: TextStyle(
                        fontSize: AppSizes.textS,
                        fontWeight: FontWeight.w600,
                        color: widget.badge.isUnlocked
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingXS * 0.5),
                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingXS,
                      vertical: AppSizes.spacingXS * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: widget.badge.isUnlocked
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      widget.badge.isUnlocked
                          ? tr('badge_unlocked')
                          : tr('badge_locked'),
                      style: TextStyle(
                        fontSize: AppSizes.textXS,
                        color: widget.badge.isUnlocked
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: (widget.index * 50).ms,
          curve: Curves.easeOut,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 300.ms,
          delay: (widget.index * 50).ms,
          curve: Curves.easeOutBack,
        );

  /// Converts icon string to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'restaurant':
        return Icons.restaurant;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'star':
        return Icons.star;
      case 'stars':
        return Icons.stars;
      case 'local_dining':
        return Icons.local_dining;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'share':
        return Icons.share;
      default:
        return Icons.emoji_events;
    }
  }
}
