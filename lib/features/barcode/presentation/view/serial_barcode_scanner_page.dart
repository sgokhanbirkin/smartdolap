// ignore_for_file: public_member_api_docs, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/services/feedback/feedback_service.dart';
import 'package:smartdolap/core/utils/haptics.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/serial_barcode_scanner_cubit.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/serial_barcode_scanner_state.dart';
import 'package:smartdolap/features/barcode/presentation/widgets/scanner_overlay_widget.dart';
import 'package:smartdolap/features/barcode/presentation/view/scanned_items_review_page.dart';

/// Serial Barcode scanner page (Cashier Mode)
/// Allows continuous scanning of multiple items
class SerialBarcodeScannerPage extends StatefulWidget {
  const SerialBarcodeScannerPage({super.key});

  @override
  State<SerialBarcodeScannerPage> createState() =>
      _SerialBarcodeScannerPageState();
}

class _SerialBarcodeScannerPageState extends State<SerialBarcodeScannerPage> {
  late MobileScannerController _controller;
  // Track previous count to trigger feedback
  int _previousItemCount = 0;

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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SerialBarcodeScannerCubit>(),
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
        body: BlocConsumer<SerialBarcodeScannerCubit, SerialBarcodeScannerState>(
          listener: (context, state) {
            // Check for new items to trigger success feedback
            if (state.scannedItems.length > _previousItemCount) {
              _previousItemCount = state.scannedItems.length;
              Haptics.success();
              // Sound effect could go here
            }

            // Check for errors
            if (state.errorMessage != null) {
              Haptics.error();

              // Special handling for product not found
              if (state.errorMessage == 'product_not_found' &&
                  state.lastScannedBarcode != null) {
                _showProductNotFoundDialog(state.lastScannedBarcode!);
              } else {
                sl<IFeedbackService>().showError(context, state.errorMessage!);
              }
            }
          },
          builder: (context, state) {
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
                          onDetect: (capture) {
                            final barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty &&
                                barcodes.first.rawValue != null) {
                              context
                                  .read<SerialBarcodeScannerCubit>()
                                  .onBarcodeDetected(barcodes.first.rawValue!);
                            }
                          },
                        ),
                        const ScannerOverlayWidget(),
                        if (state.isProcessing)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
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
                          child: Text(
                            'Scanned Items (${state.scannedItems.length})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Expanded(
                          child: state.scannedItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'Scan items to add to cart',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.all(16.w),
                                  itemCount: state.scannedItems.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 8.h),
                                  itemBuilder: (context, index) {
                                    final item = state.scannedItems[index];
                                    return _buildScannedItemCard(
                                      context,
                                      item,
                                      index,
                                    );
                                  },
                                ),
                        ),
                        // Done Button
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 32.h),
                          child: ElevatedButton(
                            onPressed: state.scannedItems.isEmpty
                                ? null
                                : () async {
                                    // Navigate to review page
                                    final result =
                                        await Navigator.push<
                                          Map<String, dynamic>
                                        >(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ScannedItemsReviewPage(
                                                  scannedItems:
                                                      state.scannedItems,
                                                ),
                                          ),
                                        );

                                    // If user confirmed and items were added successfully
                                    if (result != null &&
                                        result['success'] == true &&
                                        mounted) {
                                      // Clear the session and go back
                                      context
                                          .read<SerialBarcodeScannerCubit>()
                                          .clearSession();
                                      Navigator.pop(context);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: Text('finish'.tr()),
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
  }

  Widget _buildScannedItemCard(
    BuildContext context,
    ScannedProduct item,
    int index,
  ) {
    return Dismissible(
      key: Key('item_${item.barcode}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<SerialBarcodeScannerCubit>().removeItem(index);
        _previousItemCount--; // Decrement local count to avoid sync issues
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.shopping_bag),
                ),
          title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(item.barcode),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
        ),
      ),
    );
  }

  /// Show dialog when product is not found
  void _showProductNotFoundDialog(String barcode) {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('product_not_found_title'.tr()),
        content: Text(
          'product_not_found_message'.tr(namedArgs: {'barcode': barcode}),
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
    ).then((result) {
      if (result == 'manual') {
        // TODO: Navigate to manual add page with pre-filled barcode
        // For now, just show a message
        sl<IFeedbackService>().showInfo(
          context,
          'Manual entry not yet implemented',
        );
      }
      // If 'skip', just continue scanning
    });
  }
}
