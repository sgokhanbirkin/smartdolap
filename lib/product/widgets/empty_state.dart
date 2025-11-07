// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.messageKey,
    this.actionLabelKey,
    this.onAction,
    this.lottieUrl,
    super.key,
  });

  final String messageKey;
  final String? actionLabelKey;
  final VoidCallback? onAction;
  final String? lottieUrl;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (lottieUrl != null) ...<Widget>[
            SizedBox(
              height: 180.h,
              child: Lottie.network(
                lottieUrl!,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
          ],
          Text(
            tr(messageKey),
            style: TextStyle(fontSize: AppSizes.text),
            textAlign: TextAlign.center,
          ),
          if (actionLabelKey != null && onAction != null) ...<Widget>[
            SizedBox(height: AppSizes.verticalSpacingM),
            ElevatedButton(
              onPressed: onAction,
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
              child: Text(
                tr(actionLabelKey!),
                style: TextStyle(fontSize: AppSizes.text),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
