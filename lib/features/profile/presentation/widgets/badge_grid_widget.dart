import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart' as domain;
import 'package:smartdolap/features/profile/presentation/widgets/badge_card_widget.dart';

/// Badge grid widget for displaying all badges
class BadgeGridWidget extends StatelessWidget {
  /// Creates a badge grid
  const BadgeGridWidget({
    required this.badges,
    this.onBadgeTap,
    super.key,
  });

  /// List of badges to display
  final List<domain.Badge> badges;

  /// Optional callback when a badge is tapped
  final ValueChanged<domain.Badge>? onBadgeTap;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.padding),
          child: Text(
            tr('no_badges'),
            style: TextStyle(
              fontSize: AppSizes.textM,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(AppSizes.padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.spacingS,
        mainAxisSpacing: AppSizes.verticalSpacingS,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (BuildContext context, int index) {
        final domain.Badge badge = badges[index];
        return BadgeCardWidget(
          badge: badge,
          onTap: () => onBadgeTap?.call(badge),
        );
      },
    );
  }
}

/// Badge detail dialog widget
class BadgeDetailDialogWidget extends StatelessWidget {
  /// Creates a badge detail dialog
  const BadgeDetailDialogWidget({required this.badge, super.key});

  /// Badge to show details for
  final domain.Badge badge;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      children: <Widget>[
        Icon(
          _getIconData(badge.icon),
          size: AppSizes.icon,
          color: badge.isUnlocked
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: Text(
            tr(badge.nameKey),
            style: TextStyle(
              fontSize: AppSizes.textL,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
        ),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tr(badge.descriptionKey),
          style: TextStyle(
            fontSize: AppSizes.textM,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.5,
          ),
        ),
        if (badge.isUnlocked && badge.unlockedAt != null) ...<Widget>[
          SizedBox(height: AppSizes.verticalSpacingM),
          Text(
            tr(
              'badge_unlocked_at',
              namedArgs: <String, String>{
                'date': DateFormat('dd.MM.yyyy').format(badge.unlockedAt!),
              },
            ),
            style: TextStyle(
              fontSize: AppSizes.textS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(tr('ok')),
      ),
    ],
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
