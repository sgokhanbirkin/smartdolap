import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart' as domain;

/// Badge card widget for displaying a single badge
class BadgeCardWidget extends StatelessWidget {
  /// Creates a badge card
  const BadgeCardWidget({
    required this.badge,
    this.onTap,
    super.key,
  });

  /// Badge to display
  final domain.Badge badge;

  /// Optional tap callback
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    ),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Icon with blur effect if locked
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Icon(
                  _getIconData(badge.icon),
                  size: AppSizes.iconXL,
                  color: badge.isUnlocked
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (!badge.isUnlocked)
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
            // Badge name
            Text(
              tr(badge.nameKey),
              style: TextStyle(
                fontSize: AppSizes.textS,
                fontWeight: FontWeight.w600,
                color: badge.isUnlocked
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.spacingXS * 0.5),
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacingXS,
                vertical: AppSizes.spacingXS * 0.5,
              ),
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Text(
                badge.isUnlocked ? tr('badge_unlocked') : tr('badge_locked'),
                style: TextStyle(
                  fontSize: AppSizes.textXS,
                  color: badge.isUnlocked
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
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
