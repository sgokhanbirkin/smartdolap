// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Instructions widget for barcode scanner
/// Displays helpful text to guide users
class ScannerInstructionsWidget extends StatelessWidget {
  const ScannerInstructionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.h,
      left: 0,
      right: 0,
      child: Center(
        child:           Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20.r),
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 32.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                'point_camera_at_barcode'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                'scan_instructions_subtitle'.tr(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

