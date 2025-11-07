import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Mark as made button widget
class MarkAsMadeButtonWidget extends StatelessWidget {
  const MarkAsMadeButtonWidget({
    required this.isSaving,
    required this.onPressed,
    super.key,
  });

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      padding: EdgeInsets.all(AppSizes.padding),
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? SizedBox(
                width: AppSizes.iconS,
                height: AppSizes.iconS,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check_circle),
        label: Text(
          isSaving ? tr('save') : tr('recipe_made'),
          style: TextStyle(fontSize: AppSizes.text),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: AppSizes.spacingM,
            horizontal: AppSizes.spacingL,
          ),
          minimumSize: Size(double.infinity, AppSizes.buttonHeightL),
        ),
      ),
    ),
  );
}

