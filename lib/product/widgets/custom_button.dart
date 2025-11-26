import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_colors.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Custom button widget with theme support
class CustomButton extends StatelessWidget {
  /// Custom button constructor
  const CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.useGradient = false,
    super.key,
  });

  /// Button text
  final String text;

  /// Button onPressed callback
  final VoidCallback? onPressed;

  /// Loading state
  final bool isLoading;

  /// Whether to use gradient background instead of solid color
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? AppColors.primaryRedDark
        : AppColors.primaryRed;
    final LinearGradient gradient = isDark
        ? AppColors.redToBlueDark
        : AppColors.redToBlue;

    return Container(
      decoration: BoxDecoration(
        gradient: useGradient ? gradient : null,
        color: useGradient ? null : backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textLight,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.buttonPaddingH,
            vertical: AppSizes.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: AppSizes.iconS,
                width: AppSizes.iconS,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.textLight,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: AppSizes.text,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

