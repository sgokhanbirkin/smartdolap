// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/haptics.dart';

/// Success animation dialog
/// Displays a beautiful success animation with message
/// 
/// Usage:
/// ```dart
/// SuccessAnimationDialog.show(
///   context,
///   title: 'item_added',
///   message: 'item_added_successfully',
/// );
/// ```
class SuccessAnimationDialog {
  /// Show success dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    String? lottieAsset,
    Duration? autoDismissDuration,
  }) async {
    // Haptic feedback
    await Haptics.success();

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessAnimationDialogWidget(
        title: title,
        message: message,
        lottieAsset: lottieAsset,
        autoDismissDuration: autoDismissDuration,
      ),
    );
  }
}

class _SuccessAnimationDialogWidget extends StatefulWidget {
  final String title;
  final String? message;
  final String? lottieAsset;
  final Duration? autoDismissDuration;

  const _SuccessAnimationDialogWidget({
    required this.title,
    this.message,
    this.lottieAsset,
    this.autoDismissDuration,
  });

  @override
  State<_SuccessAnimationDialogWidget> createState() =>
      _SuccessAnimationDialogWidgetState();
}

class _SuccessAnimationDialogWidgetState
    extends State<_SuccessAnimationDialogWidget> {
  @override
  void initState() {
    super.initState();

    // Auto dismiss after duration
    if (widget.autoDismissDuration != null) {
      Future<void>.delayed(widget.autoDismissDuration!, () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } else {
      // Default 2 seconds
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success animation
            _buildAnimation(),

            SizedBox(height: AppSizes.verticalSpacingL),

            // Title
            Text(
              widget.title.tr(),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            // Message
            if (widget.message != null) ...[
              SizedBox(height: AppSizes.verticalSpacingM),
              Text(
                widget.message!.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    // If custom Lottie asset provided, use it
    if (widget.lottieAsset != null) {
      return Lottie.asset(
        widget.lottieAsset!,
        width: 120.w,
        height: 120.h,
        repeat: false,
      );
    }

    // Otherwise, use built-in animated checkmark
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle,
        size: 80.sp,
        color: Colors.green,
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(
          delay: 200.ms,
          duration: 1000.ms,
          color: Colors.white.withValues(alpha: 0.5),
        );
  }
}

/// Loading animation overlay
/// Shows a loading spinner with optional message
class LoadingAnimationOverlay {
  static OverlayEntry? _overlayEntry;

  /// Show loading overlay
  static void show(
    BuildContext context, {
    String? message,
  }) {
    hide(); // Hide any existing overlay

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlayWidget(message: message),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide loading overlay
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _LoadingOverlayWidget extends StatelessWidget {
  final String? message;

  const _LoadingOverlayWidget({this.message});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(AppSizes.padding * 1.5),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: colors.primary,
              ),
              if (message != null) ...[
                SizedBox(height: AppSizes.verticalSpacingM),
                Text(
                  message!.tr(),
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Error animation dialog
class ErrorAnimationDialog {
  /// Show error dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    // Haptic feedback
    await Haptics.error();

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _ErrorAnimationDialogWidget(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}

class _ErrorAnimationDialogWidget extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ErrorAnimationDialogWidget({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 80.sp,
                color: colors.error,
              ),
            )
                .animate()
                .shake(duration: 600.ms)
                .fadeIn(),

            SizedBox(height: AppSizes.verticalSpacingL),

            // Title
            Text(
              title.tr(),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Message
            if (message != null) ...[
              SizedBox(height: AppSizes.verticalSpacingM),
              Text(
                message!.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: AppSizes.verticalSpacingL),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Haptics.light();
                  Navigator.of(context).pop();
                  onAction?.call();
                },
                child: Text(
                  (actionLabel ?? 'ok').tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

