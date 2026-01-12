// ignore_for_file: public_member_api_docs, use_build_context_synchronously, prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/services/audio_feedback_service.dart';
import 'package:smartdolap/core/services/feedback/feedback_service.dart';
import 'package:smartdolap/core/utils/haptics.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/domain/services/scan_queue_manager.dart';
import 'package:smartdolap/features/barcode/presentation/view/scanned_items_review_page.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/serial_barcode_scanner_cubit_v2.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/serial_barcode_scanner_state_v2.dart';
import 'package:smartdolap/features/barcode/presentation/widgets/scanner_overlay_widget.dart';

/// Serial Barcode scanner page V2 with queue-based processing
/// Provides instant feedback and non-blocking UI
class SerialBarcodeScannerPageV2 extends StatefulWidget {
  const SerialBarcodeScannerPageV2({super.key});

  @override
  State<SerialBarcodeScannerPageV2> createState() =>
      _SerialBarcodeScannerPageV2State();
}

class _SerialBarcodeScannerPageV2State
    extends State<SerialBarcodeScannerPageV2> {
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<SerialBarcodeScannerCubitV2>(),
    child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('serial_mode'.tr()),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              Haptics.light();
              _controller.toggleTorch();
            },
          ),
        ],
      ),
      body:
          BlocConsumer<
            SerialBarcodeScannerCubitV2,
            SerialBarcodeScannerStateV2
          >(
            listener: _handleFeedbackEvents,
            builder: (BuildContext context, SerialBarcodeScannerStateV2 state) {
              return Stack(
                children: [
                  // Top Half: Camera View
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 0.5.sh,
                    child: ClipRect(
                      child: Stack(
                        children: [
                          MobileScanner(
                            controller: _controller,
                            onDetect: (BarcodeCapture capture) {
                              final List<Barcode> barcodes = capture.barcodes;
                              if (barcodes.isNotEmpty &&
                                  barcodes.first.rawValue != null) {
                                context
                                    .read<SerialBarcodeScannerCubitV2>()
                                    .onBarcodeDetected(
                                      barcodes.first.rawValue!,
                                    );
                              }
                            },
                          ),
                          const ScannerOverlayWidget(),
                          // Status indicator
                          Positioned(
                            top: 16.h,
                            left: 16.w,
                            right: 16.w,
                            child: _buildStatusCard(state),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Half: Scanned List
                  Positioned(
                    top: 0.5.sh,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.r),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Scanned Items (${state.queuedScans.length})',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (state.pendingCount > 0)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 12.w,
                                          height: 12.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '${state.pendingCount} pending',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: state.queuedScans.isEmpty
                                ? Center(
                                    child: Text(
                                      'Scan items to add to cart',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.all(16.w),
                                    itemCount: state.queuedScans.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 8.h),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final QueuedScan scan =
                                              state.queuedScans[index];
                                          return _buildScanCard(
                                            context,
                                            scan,
                                            index,
                                          );
                                        },
                                  ),
                          ),
                          // Done Button with Safe Area
                          SafeArea(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                8.w,
                                16.w,
                                16.h,
                              ),
                              child: ElevatedButton(
                                onPressed: state.foundCount > 0
                                    ? () async {
                                        final List<ScannedProduct>
                                        products = context
                                            .read<SerialBarcodeScannerCubitV2>()
                                            .getFoundProducts();

                                        final Map<String, dynamic>? result =
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute<
                                                Map<String, dynamic>
                                              >(
                                                builder: (_) =>
                                                    ScannedItemsReviewPage(
                                                      scannedItems: products,
                                                    ),
                                              ),
                                            );

                                        if (result != null &&
                                            result['success'] == true &&
                                            mounted) {
                                          context
                                              .read<
                                                SerialBarcodeScannerCubitV2
                                              >()
                                              .clearSession();
                                          if (mounted) {
                                            Navigator.pop(context);
                                          }
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                ),
                                child: Text('finish'.tr()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    ),
  );

  Widget _buildStatusCard(SerialBarcodeScannerStateV2 state) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatusItem(
          icon: Icons.check_circle,
          label: 'Found',
          value: state.foundCount.toString(),
          color: Colors.green,
        ),
        _buildStatusItem(
          icon: Icons.pending,
          label: 'Pending',
          value: state.pendingCount.toString(),
          color: Colors.orange,
        ),
        _buildStatusItem(
          icon: Icons.qr_code_scanner,
          label: 'Total',
          value: state.queuedScans.length.toString(),
          color: Colors.white,
        ),
      ],
    ),
  );

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 20.sp),
      SizedBox(height: 4.h),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: TextStyle(color: Colors.white70, fontSize: 10.sp),
      ),
    ],
  );

  Widget _buildScanCard(BuildContext context, QueuedScan scan, int index) =>
      Dismissible(
        key: Key(
          'scan_${scan.barcode}_${scan.timestamp.millisecondsSinceEpoch}',
        ),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 16.w),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          context.read<SerialBarcodeScannerCubitV2>().removeScan(index);
        },
        child: Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: _buildLeadingWidget(scan),
            title: _buildTitleWidget(scan),
            subtitle: Text(scan.barcode),
            trailing: _buildTrailingWidget(scan),
          ),
        ),
      );

  Widget _buildLeadingWidget(QueuedScan scan) {
    if (scan.status == ScanStatus.pending ||
        scan.status == ScanStatus.processing) {
      return Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange,
            ),
          ),
        ),
      );
    }

    if (scan.product?.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          scan.product!.imageUrl!,
          width: 50.w,
          height: 50.h,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        scan.status == ScanStatus.notFound
            ? Icons.help_outline
            : Icons.shopping_bag,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildTitleWidget(QueuedScan scan) {
    switch (scan.status) {
      case ScanStatus.pending:
        return Text(
          'Waiting...',
          style: TextStyle(color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case ScanStatus.processing:
        return Text(
          'Processing...',
          style: TextStyle(color: Colors.orange),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case ScanStatus.found:
        return Text(
          scan.product!.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case ScanStatus.notFound:
        return Text(
          'Product not found',
          style: TextStyle(color: Colors.red[700]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case ScanStatus.error:
        return const Text(
          'Error',
          style: TextStyle(color: Colors.red),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  Widget _buildTrailingWidget(QueuedScan scan) {
    switch (scan.status) {
      case ScanStatus.pending:
      case ScanStatus.processing:
        return Icon(Icons.pending, color: Colors.orange, size: 24.sp);
      case ScanStatus.found:
        return Icon(Icons.check_circle, color: Colors.green, size: 24.sp);
      case ScanStatus.notFound:
        return Icon(Icons.cancel, color: Colors.red, size: 24.sp);
      case ScanStatus.error:
        return Icon(Icons.error, color: Colors.red, size: 24.sp);
    }
  }

  void _handleFeedbackEvents(
    BuildContext context,
    SerialBarcodeScannerStateV2 state,
  ) {
    switch (state.lastFeedbackEvent) {
      case FeedbackEvent.scanDetected:
        // Instant feedback on barcode detection - "DIT" sound!
        Haptics.medium();
        AudioFeedbackService.playDitSound();
        break;
      case FeedbackEvent.success:
        // Product found feedback
        Haptics.success();
        break;
      case FeedbackEvent.notFound:
        // Product not found feedback
        Haptics.error();
        AudioFeedbackService.playErrorBeep();
        // Optionally show dialog
        if (state.lastErrorBarcode != null) {
          _showProductNotFoundDialog(state.lastErrorBarcode!);
        }
        break;
      case FeedbackEvent.error:
        // Error feedback
        Haptics.error();
        AudioFeedbackService.playErrorBeep();
        if (state.lastErrorMessage != null) {
          sl<IFeedbackService>().showError(context, state.lastErrorMessage!);
        }
        break;
      case FeedbackEvent.none:
        // No feedback needed
        break;
    }
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('product_not_found_title'.tr()),
        content: Text(
          'product_not_found_message'.tr(
            namedArgs: <String, String>{'barcode': barcode},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'skip'),
            child: Text('skip_item'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'manual'),
            child: Text('add_manually'.tr()),
          ),
        ],
      ),
    ).then((String? result) {
      if (result == 'manual') {
        sl<IFeedbackService>().showInfo(
          context,
          'Manual entry not yet implemented',
        );
      }
    });
  }
}
