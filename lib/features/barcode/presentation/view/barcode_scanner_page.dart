// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/services/feedback/feedback_service.dart';
import 'package:smartdolap/core/utils/haptics.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/barcode_scanner_cubit.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/barcode_scanner_state.dart';
import 'package:smartdolap/features/barcode/presentation/widgets/add_scanned_product_sheet.dart';
import 'package:smartdolap/features/barcode/presentation/widgets/scanner_instructions_widget.dart';
import 'package:smartdolap/features/barcode/presentation/widgets/scanner_overlay_widget.dart';

/// Barcode scanner page
/// Allows users to scan product barcodes to quickly add items to pantry
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late MobileScannerController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<BarcodeScannerCubit>(),
    child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('scan_barcode'.tr()),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Flash toggle
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              Haptics.light();
              _controller.toggleTorch();
            },
            tooltip: 'toggle_flash'.tr(),
          ),
          // Camera flip
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () {
              Haptics.light();
              _controller.switchCamera();
            },
            tooltip: 'switch_camera'.tr(),
          ),
        ],
      ),
      body: BlocListener<BarcodeScannerCubit, BarcodeScannerState>(
        listener: _handleStateChange,
        child: Stack(
          children: [
            // Camera view
            MobileScanner(controller: _controller, onDetect: _onDetect),

            // Scanner overlay (viewfinder frame)
            const ScannerOverlayWidget(),

            // Instructions
            const ScannerInstructionsWidget(),

            // Manual entry button
            _buildManualEntryButton(),

            // Processing indicator
            if (_isProcessing) _buildProcessingIndicator(),
          ],
        ),
      ),
    ),
  );

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? barcode = barcodes.first.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() => _isProcessing = true);

    // Haptic feedback for scan detected
    Haptics.medium();

    // Trigger barcode lookup
    context.read<BarcodeScannerCubit>().onBarcodeDetected(barcode);
  }

  void _handleStateChange(BuildContext context, BarcodeScannerState state) {
    state.when(
      ready: () {
        setState(() => _isProcessing = false);
      },
      scanning: (barcode) {
        // Show loading - already handled by _isProcessing
      },
      productFound: (product) {
        setState(() => _isProcessing = false);

        // Success haptic
        Haptics.success();

        // Show add product sheet
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddScannedProductSheet(product: product),
        ).then((_) {
          // Reset cubit when sheet is dismissed
          // ignore: use_build_context_synchronously
          context.read<BarcodeScannerCubit>().reset();
        });
      },
      productNotFound: (barcode) {
        setState(() => _isProcessing = false);

        // Error haptic
        Haptics.error();

        // Show error message
        sl<IFeedbackService>().showError(context, 'product_not_found');

        // Show manual entry dialog
        _showManualEntryDialog(barcode);

        // Reset after showing dialog
        context.read<BarcodeScannerCubit>().reset();
      },
      error: (message, barcode) {
        setState(() => _isProcessing = false);

        // Error haptic
        Haptics.error();

        // Show error message
        sl<IFeedbackService>().showError(context, message);

        // Reset cubit
        context.read<BarcodeScannerCubit>().reset();
      },
      permissionDenied: () {
        setState(() => _isProcessing = false);

        // Show permission error
        sl<IFeedbackService>().showError(context, 'camera_permission_denied');

        // Go back
        Navigator.pop(context);
      },
    );
  }

  Widget _buildManualEntryButton() {
    return Positioned(
      bottom: 40.h,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Haptics.light();
            _showManualEntryDialog(null);
          },
          icon: const Icon(Icons.edit),
          label: Text('enter_manually'.tr()),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  void _showManualEntryDialog(String? barcode) {
    // Navigate to manual add page with optional barcode
    Navigator.pushNamed(
      context,
      '/pantry/add',
      arguments: <String, dynamic>{if (barcode != null) 'barcode': barcode},
    );
  }
}
