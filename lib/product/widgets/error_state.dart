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
  Widget build(BuildContext context) {
    // Responsive sizing based on screen width
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final double iconSize = isTablet ? 120.sp : 80.sp;
    final double animationSize = isTablet ? 230.h : 180.h;
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
                // Error animation or icon
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
                ] else ...<Widget>[
                  Icon(
                    icon ?? Icons.error_outline,
                    size: iconSize,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: AppSizes.verticalSpacingL),
                ],
                // Error message
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
                        fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
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
                        fontSize: isTablet ? AppSizes.textL : AppSizes.textM,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context, double size) => Icon(
    icon ?? Icons.error_outline,
    size: size,
    color: Theme.of(context).colorScheme.error,
  );
}

