// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Enhanced empty state widget with Lottie animations and CTA buttons
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.messageKey,
    this.actionLabelKey,
    this.onAction,
    this.lottieUrl,
    this.lottieAsset,
    this.icon,
    super.key,
  });

  final String messageKey;
  final String? actionLabelKey;
  final VoidCallback? onAction;
  final String? lottieUrl;
  final String? lottieAsset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen width
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final double iconSize = isTablet ? 120.sp : 80.sp;
    final double animationSize = isTablet ? 250.h : 200.h;
    final double maxWidth = isTablet ? 500.w : double.infinity;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.padding * (isTablet ? 2 : 1.5)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Lottie animation or icon
                if (lottieAsset != null) ...<Widget>[
                  SizedBox(
                    height: animationSize,
                    width: animationSize,
                    child: Lottie.asset(
                      lottieAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildFallbackIcon(context, iconSize),
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingL),
                ] else if (lottieUrl != null) ...<Widget>[
                  SizedBox(
                    height: animationSize,
                    width: animationSize,
                    child: Lottie.network(
                      lottieUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildFallbackIcon(context, iconSize),
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingL),
                ] else if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: iconSize,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: AppSizes.verticalSpacingL),
                ],
                // Message
                Text(
                  tr(messageKey),
                  style: TextStyle(
                    fontSize: isTablet ? AppSizes.textXL : AppSizes.textL,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.verticalSpacingM),
                // CTA Button
                if (actionLabelKey != null && onAction != null) ...<Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(
                        tr(actionLabelKey!),
                        style: TextStyle(
                          fontSize: isTablet ? AppSizes.textL : AppSizes.textM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          isTablet ? AppSizes.buttonHeightL : AppSizes.buttonHeight,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.buttonPaddingH,
                          vertical: AppSizes.buttonPaddingV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context, double size) => Icon(
    icon ?? Icons.inbox_outlined,
    size: size,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}
