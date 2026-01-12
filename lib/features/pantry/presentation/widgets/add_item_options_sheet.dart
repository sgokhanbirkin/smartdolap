// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/utils/haptics.dart';

/// Add item method options
enum AddItemMethod { manual, barcodeScan, receiptScan, visualScan }

/// Bottom sheet for selecting how to add pantry items
class AddItemOptionsSheet extends StatelessWidget {
  final void Function(AddItemMethod) onMethodSelected;

  const AddItemOptionsSheet({super.key, required this.onMethodSelected});

  /// Show the bottom sheet
  static Future<AddItemMethod?> show(BuildContext context) {
    return showModalBottomSheet<AddItemMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Important for glassmorphism
      barrierColor: Colors.black.withValues(alpha: 0.5), // Custom barrier color
      builder: (context) => AddItemOptionsSheet(
        onMethodSelected: (method) {
          Navigator.pop(context, method);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 12.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'add_item_title'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Options grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _OptionCard(
                              icon: Icons.edit_note,
                              title: 'manual_entry'.tr(),
                              subtitle: 'manual_entry_desc'.tr(),
                              color: Colors.blue,
                              onTap: () {
                                Haptics.light();
                                onMethodSelected(AddItemMethod.manual);
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _OptionCard(
                              icon: Icons.qr_code_scanner,
                              title: 'barcode_scan'.tr(),
                              subtitle: 'barcode_scan_desc'.tr(),
                              color: Colors.green,
                              badge: 'batch'.tr(),
                              onTap: () {
                                Haptics.light();
                                onMethodSelected(AddItemMethod.barcodeScan);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _OptionCard(
                              icon: Icons.receipt_long,
                              title: 'receipt_scan'.tr(),
                              subtitle: 'receipt_scan_desc'.tr(),
                              color: Colors.orange,
                              onTap: () {
                                Haptics.light();
                                onMethodSelected(AddItemMethod.receiptScan);
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _OptionCard(
                              icon: Icons.camera_alt,
                              title: 'visual_scan'.tr(),
                              subtitle: 'visual_scan_desc'.tr(),
                              color: Colors.purple,
                              badge: 'batch'.tr(),
                              onTap: () {
                                Haptics.light();
                                onMethodSelected(AddItemMethod.visualScan);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                if (badge != null) ...[
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
