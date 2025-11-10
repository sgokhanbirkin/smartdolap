import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart' as domain;
import 'package:smartdolap/features/profile/presentation/widgets/badge_card_widget.dart';

/// Badge preview widget - Shows 3 important badges horizontally
class BadgePreviewWidget extends StatelessWidget {
  /// Creates a badge preview widget
  const BadgePreviewWidget({
    required this.badges,
    required this.onViewAll,
    this.onBadgeTap,
    super.key,
  });

  /// List of badges to display (should be 3)
  final List<domain.Badge> badges;

  /// Callback when "View All" is tapped
  final VoidCallback onViewAll;

  /// Optional callback when a badge is tapped
  final ValueChanged<domain.Badge>? onBadgeTap;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.cardPadding * 1.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.emoji_events,
                    size: AppSizes.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: Text(
                      tr('badges_title'),
                      style: TextStyle(
                        fontSize: AppSizes.textL,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onViewAll,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: AppSizes.iconXS,
                    ),
                    label: Text(tr('view_all')),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingS,
                        vertical: AppSizes.spacingXS,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.verticalSpacingL),
              if (badges.isEmpty)
                Center(
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
                )
              else
                SizedBox(
                  height: 140,
                  child: Row(
                    children: badges
                        .asMap()
                        .entries
                        .map(
                          (MapEntry<int, domain.Badge> entry) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.spacingS * 0.5,
                              ),
                              child: BadgeCardWidget(
                                badge: entry.value,
                                index: entry.key,
                                onTap: () => onBadgeTap?.call(entry.value),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      );
}

