// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/haptics.dart';

/// Modern empty state widget with animations and better UX
/// 
/// Provides a beautiful, animated empty state with:
/// - Icon/illustration
/// - Title and description
/// - Primary and secondary actions
/// - Smooth animations
class ModernEmptyState extends StatelessWidget {
  final IconData? icon;
  final String? illustrationPath;
  final String title;
  final String description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? iconColor;
  final double iconSize;

  const ModernEmptyState({
    this.icon,
    this.illustrationPath,
    required this.title,
    required this.description,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconColor,
    this.iconSize = 120,
    super.key,
  }) : assert(
          icon != null || illustrationPath != null,
          'Either icon or illustrationPath must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or illustration
            _buildIcon(context, colors),

            SizedBox(height: AppSizes.verticalSpacingXL),

            // Title
            Text(
              title.tr(),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            SizedBox(height: AppSizes.verticalSpacingM),

            // Description
            Text(
              description.tr(),
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            SizedBox(height: AppSizes.verticalSpacingXXL),

            // Primary action
            if (primaryActionLabel != null && onPrimaryAction != null)
              _buildPrimaryButton(context, colors),

            // Secondary action
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              SizedBox(height: AppSizes.verticalSpacingM),
              _buildSecondaryButton(context, colors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ColorScheme colors) {
    Widget iconWidget;

    if (illustrationPath != null) {
      iconWidget = Image.asset(
        illustrationPath!,
        width: iconSize.w,
        height: iconSize.h,
      );
    } else {
      iconWidget = Container(
        width: iconSize.w,
        height: iconSize.h,
        decoration: BoxDecoration(
          color: (iconColor ?? colors.primary).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: (iconSize * 0.5).sp,
          color: iconColor ?? colors.primary,
        ),
      );
    }

    return iconWidget
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
        .then()
        .shimmer(
          delay: 1000.ms,
          duration: 2000.ms,
          color: Colors.white.withValues(alpha: 0.3),
        );
  }

  Widget _buildPrimaryButton(BuildContext context, ColorScheme colors) {
    return ElevatedButton(
      onPressed: () {
        Haptics.medium();
        onPrimaryAction?.call();
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 32.w,
          vertical: 16.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
      ),
      child: Text(
        primaryActionLabel!.tr(),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildSecondaryButton(BuildContext context, ColorScheme colors) {
    return TextButton(
      onPressed: () {
        Haptics.light();
        onSecondaryAction?.call();
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 32.w,
          vertical: 16.h,
        ),
      ),
      child: Text(
        secondaryActionLabel!.tr(),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: colors.primary,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }
}

