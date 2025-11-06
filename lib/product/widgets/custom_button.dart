import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Custom button widget
class CustomButton extends StatelessWidget {
  /// Custom button constructor
  const CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Button text
  final String text;

  /// Button onPressed callback
  final VoidCallback onPressed;

  /// Loading state
  final bool isLoading;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, AppSizes.buttonHeight),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.buttonPaddingH,
            vertical: AppSizes.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: AppSizes.iconS,
                width: AppSizes.iconS,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                ),
              )
            : Text(
                text,
                style: TextStyle(fontSize: AppSizes.text),
              ),
      );
}
