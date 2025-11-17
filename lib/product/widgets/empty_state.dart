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
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
          // Lottie animation or icon
          if (lottieAsset != null) ...<Widget>[
            SizedBox(
              height: 200.h,
              width: 200.w,
              child: Lottie.asset(
                lottieAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildFallbackIcon(context),
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingL),
          ] else if (lottieUrl != null) ...<Widget>[
            SizedBox(
              height: 200.h,
              width: 200.w,
              child: Lottie.network(
                lottieUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildFallbackIcon(context),
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingL),
          ] else if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: 80.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppSizes.verticalSpacingL),
          ],
          // Message
          Text(
            tr(messageKey),
            style: TextStyle(
              fontSize: AppSizes.textL,
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
                    fontSize: AppSizes.textM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity, AppSizes.buttonHeight),
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
  );

  Widget _buildFallbackIcon(BuildContext context) => Icon(
    icon ?? Icons.inbox_outlined,
    size: 80.sp,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}
