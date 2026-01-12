// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Scanner overlay widget with viewfinder frame
/// Creates a visual guide for users to align the barcode
class ScannerOverlayWidget extends StatelessWidget {
  const ScannerOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double scanAreaSize = 250.w;

    return Stack(
      children: [
        // Dark overlay with transparent center
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black54,
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  height: scanAreaSize,
                  width: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner borders
        Center(
          child: SizedBox(
            height: scanAreaSize,
            width: scanAreaSize,
            child: Stack(
              children: [
                // Top-left corner
                Positioned(
                  top: 0,
                  left: 0,
                  child: _buildCorner(
                    horizontal: CrossAxisAlignment.start,
                    vertical: CrossAxisAlignment.start,
                  ),
                ),
                // Top-right corner
                Positioned(
                  top: 0,
                  right: 0,
                  child: _buildCorner(
                    horizontal: CrossAxisAlignment.end,
                    vertical: CrossAxisAlignment.start,
                  ),
                ),
                // Bottom-left corner
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _buildCorner(
                    horizontal: CrossAxisAlignment.start,
                    vertical: CrossAxisAlignment.end,
                  ),
                ),
                // Bottom-right corner
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildCorner(
                    horizontal: CrossAxisAlignment.end,
                    vertical: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({
    required CrossAxisAlignment horizontal,
    required CrossAxisAlignment vertical,
  }) {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: horizontal,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (vertical == CrossAxisAlignment.start)
            _buildCornerLine(40.w, 4.h)
          else
            _buildCornerLine(4.w, 40.h),
          SizedBox(
            height: 4.h,
            width: 4.w,
          ),
          if (vertical == CrossAxisAlignment.start)
            _buildCornerLine(4.w, 40.h)
          else
            _buildCornerLine(40.w, 4.h),
        ],
      ),
    );
  }

  Widget _buildCornerLine(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}

