// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Feedback service for showing user notifications
/// Follows SOLID principles:
/// - Single Responsibility: Only handles user feedback
/// - Dependency Inversion: Uses BuildContext abstraction
abstract class IFeedbackService {
  /// Show success message
  void showSuccess(BuildContext context, String messageKey, {List<String>? args});

  /// Show error message
  void showError(BuildContext context, String messageKey, {List<String>? args, String? details});

  /// Show info message
  void showInfo(BuildContext context, String messageKey, {List<String>? args});

  /// Show warning message
  void showWarning(BuildContext context, String messageKey, {List<String>? args});

  /// Show loading message
  void showLoading(BuildContext context, String messageKey);

  /// Hide current message
  void hideCurrent(BuildContext context);
}

/// Implementation of feedback service
/// Uses SnackBar for notifications with consistent styling
class FeedbackService implements IFeedbackService {
  const FeedbackService();

  @override
  void showSuccess(BuildContext context, String messageKey, {List<String>? args}) {
    _showSnackBar(
      context,
      message: args != null ? tr(messageKey, args: args) : tr(messageKey),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      icon: Icons.check_circle,
      iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  @override
  void showError(BuildContext context, String messageKey, {List<String>? args, String? details}) {
    _showSnackBar(
      context,
      message: args != null ? tr(messageKey, args: args) : tr(messageKey),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      icon: Icons.error_outline,
      iconColor: Theme.of(context).colorScheme.onErrorContainer,
      details: details,
    );
  }

  @override
  void showInfo(BuildContext context, String messageKey, {List<String>? args}) {
    _showSnackBar(
      context,
      message: args != null ? tr(messageKey, args: args) : tr(messageKey),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      icon: Icons.info_outline,
      iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
    );
  }

  @override
  void showWarning(BuildContext context, String messageKey, {List<String>? args}) {
    _showSnackBar(
      context,
      message: args != null ? tr(messageKey, args: args) : tr(messageKey),
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      icon: Icons.warning_amber_rounded,
      iconColor: Theme.of(context).colorScheme.onTertiaryContainer,
    );
  }

  @override
  void showLoading(BuildContext context, String messageKey) {
    _showSnackBar(
      context,
      message: tr(messageKey),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      isLoading: true,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void hideCurrent(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Color? iconColor,
    String? details,
    bool isLoading = false,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: isLoading
            ? Row(
                children: <Widget>[
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.textM,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(
                      icon,
                      color: iconColor,
                      size: AppSizes.iconL,
                    ),
                    SizedBox(width: AppSizes.spacingS),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          message,
                          style: TextStyle(
                            color: iconColor ?? Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizes.textM,
                          ),
                        ),
                        if (details != null && details.isNotEmpty) ...<Widget>[
                          SizedBox(height: AppSizes.spacingXS),
                          Text(
                            details,
                            style: TextStyle(
                              color: (iconColor ?? Theme.of(context).colorScheme.onSurface)
                                  .withValues(alpha: 0.8),
                              fontSize: AppSizes.textS,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: AppSizes.padding,
          right: AppSizes.padding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}

