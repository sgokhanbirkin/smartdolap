// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/category_colors.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

class PantryItemCard extends StatelessWidget {
  const PantryItemCard({required this.item, this.onTap, super.key});

  final PantryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        builder: (BuildContext context, double scale, Widget? child) =>
            Transform.scale(scale: scale, child: child),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius * 1.1),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius * 1.5),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.cardPadding,
                    vertical: AppSizes.cardPadding * 0.8,
                  ),
                  child: Row(
                    children: <Widget>[
                      // Icon container - Category colored
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: item.category != null
                              ? CategoryColors.getCategoryColor(item.category!)
                              : Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                        child: Icon(
                          Icons.shopping_basket_outlined,
                          size: AppSizes.icon,
                          color: item.category != null
                              ? CategoryColors.getCategoryIconColor(item.category!)
                              : Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: AppSizes.text,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: AppSizes.spacingXS),
                            Text(
                              '${item.quantity} ${item.unit}'.trim(),
                              style: TextStyle(
                                fontSize: AppSizes.textS,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Expiry date - More prominent
                      if (item.expiryDate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              size: AppSizes.iconS,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(height: AppSizes.spacingXS * 0.5),
                            Text(
                              _formatDate(item.expiryDate!),
                              style: TextStyle(
                                fontSize: AppSizes.textXS,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                // Category badge - Top right
                if (item.category != null)
                  Positioned(
                    top: AppSizes.spacingXS,
                    right: AppSizes.spacingXS,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: CategoryColors.getCategoryBadgeColor(item.category!),
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        item.category!,
                        style: TextStyle(
                          fontSize: AppSizes.textXS,
                          fontWeight: FontWeight.w600,
                          color: CategoryColors.getCategoryBadgeTextColor(item.category!),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
