import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Animated badge widget with scale and fade effects
class AnimatedBadge extends StatelessWidget {
  /// Creates an animated badge
  const AnimatedBadge({
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.delay = 0,
    super.key,
  });

  /// Badge label text
  final String label;

  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Optional icon
  final IconData? icon;

  /// Animation delay in milliseconds
  final int delay;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBgColor =
        backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;
    final Color effectiveTextColor =
        textColor ?? Theme.of(context).colorScheme.onPrimaryContainer;

    return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.spacingS,
            vertical: AppSizes.spacingXS * 0.5,
          ),
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: AppSizes.spacingXS,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: AppSizes.iconXS, color: effectiveTextColor),
                SizedBox(width: AppSizes.spacingXS),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.textXS,
                  fontWeight: FontWeight.w600,
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: delay.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 300.ms,
          delay: delay.ms,
          curve: Curves.easeOutBack,
        );
  }
}

/// Pulse animation badge for notifications/counts
class PulseBadge extends StatefulWidget {
  /// Creates a pulse badge
  const PulseBadge({
    required this.count,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  /// Count to display
  final int count;

  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  @override
  State<PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<PulseBadge> {
  @override
  Widget build(BuildContext context) {
    final Color effectiveBgColor =
        widget.backgroundColor ?? Theme.of(context).colorScheme.error;
    final Color effectiveTextColor =
        widget.textColor ?? Theme.of(context).colorScheme.onError;

    return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.count > 9
                ? AppSizes.spacingS
                : AppSizes.spacingXS * 0.75,
            vertical: AppSizes.spacingXS * 0.5,
          ),
          decoration: BoxDecoration(
            color: effectiveBgColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            widget.count > 99 ? '99+' : '${widget.count}',
            style: TextStyle(
              fontSize: AppSizes.textXS,
              fontWeight: FontWeight.w700,
              color: effectiveTextColor,
            ),
          ),
        )
        .animate(
          onPlay: (AnimationController controller) => 
              controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }
}
