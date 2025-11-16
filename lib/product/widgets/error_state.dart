// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Error state widget with retry button
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.messageKey,
    required this.onRetry,
    this.lottieAsset,
    this.lottieUrl,
    this.icon,
    this.errorDetails,
    super.key,
  });

  final String messageKey;
  final VoidCallback onRetry;
  final String? lottieAsset;
  final String? lottieUrl;
  final IconData? icon;
  final String? errorDetails;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.padding * 1.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Error animation or icon
          if (lottieAsset != null) ...<Widget>[
            SizedBox(
              height: 180.h,
              width: 180.w,
              child: Lottie.asset(
                lottieAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildFallbackIcon(context),
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingL),
          ] else if (lottieUrl != null) ...<Widget>[
            SizedBox(
              height: 180.h,
              width: 180.w,
              child: Lottie.network(
                lottieUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildFallbackIcon(context),
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingL),
          ] else ...<Widget>[
            Icon(
              icon ?? Icons.error_outline,
              size: 80.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: AppSizes.verticalSpacingL),
          ],
          // Error message
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
          // Error details (optional)
          if (errorDetails != null && errorDetails!.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSizes.verticalSpacingS),
            Container(
              padding: EdgeInsets.all(AppSizes.spacingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Text(
                errorDetails!,
                style: TextStyle(
                  fontSize: AppSizes.textS,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          SizedBox(height: AppSizes.verticalSpacingXL),
          // Retry button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(
                tr('retry'),
                style: TextStyle(
                  fontSize: AppSizes.textM,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
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
      ),
    ),
  );

  Widget _buildFallbackIcon(BuildContext context) => Icon(
    icon ?? Icons.error_outline,
    size: 80.sp,
    color: Theme.of(context).colorScheme.error,
  );
}

