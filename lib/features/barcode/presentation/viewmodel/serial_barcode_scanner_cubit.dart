// ignore_for_file: public_member_api_docs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/domain/use_cases/scan_product_barcode_usecase.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/serial_barcode_scanner_state.dart';

/// Cubit for managing serial barcode scanner state (Cashier Mode)
class SerialBarcodeScannerCubit extends Cubit<SerialBarcodeScannerState> {
  final ScanProductBarcodeUseCase _scanProductUseCase;

  // Internal cooldown tracking: Barcode -> Last Scanned Time
  final Map<String, DateTime> _cooldowns = {};

  // Cooldown duration
  static const Duration _cooldownDuration = Duration(seconds: 3);

  SerialBarcodeScannerCubit(this._scanProductUseCase)
    : super(const SerialBarcodeScannerState());

  /// Handle a detected barcode
  Future<void> onBarcodeDetected(String barcode) async {
    // 1. Check cooldown
    final now = DateTime.now();
    if (_cooldowns.containsKey(barcode)) {
      final lastScanned = _cooldowns[barcode]!;
      if (now.difference(lastScanned) < _cooldownDuration) {
        // Cooldown active, ignore this scan
        return;
      }
    }

    // 2. Update cooldown immediately to prevent double-hits while processing
    _cooldowns[barcode] = now;

    // 3. Process scan
    emit(
      state.copyWith(
        isProcessing: true,
        lastScannedBarcode: barcode,
        errorMessage: null, // Clear previous error
      ),
    );

    try {
      Logger.info('[SerialScanner] Processing barcode: $barcode');
      final ScannedProduct? product = await _scanProductUseCase(barcode);

      if (product != null) {
        // Product found - add to list
        Logger.info('[SerialScanner] Product found: ${product.name}');

        final updatedList = List<ScannedProduct>.from(state.scannedItems)
          ..insert(0, product); // Add to top

        emit(
          state.copyWith(
            isProcessing: false,
            scannedItems: updatedList,
            errorMessage: null,
          ),
        );
      } else {
        // Product not found
        Logger.info('[SerialScanner] Product not found for: $barcode');
        emit(
          state.copyWith(
            isProcessing: false,
            errorMessage: 'product_not_found',
          ),
        );

        // Note: We might want to clear cooldown if not found,
        // to allow strict retry?
        // But for "Cashier" mode, maybe it's better to just ignore it for 3s
        // so user doesn't get spammed with "Not Found" errors continuously.
      }
    } catch (e, stackTrace) {
      Logger.error('[SerialScanner] Error scanning $barcode', e, stackTrace);
      emit(state.copyWith(isProcessing: false, errorMessage: 'scan_error'));
    }
  }

  /// Remove an item from the scanned list (if user swills it away)
  void removeItem(int index) {
    if (index >= 0 && index < state.scannedItems.length) {
      final updatedList = List<ScannedProduct>.from(state.scannedItems)
        ..removeAt(index);
      emit(state.copyWith(scannedItems: updatedList));
    }
  }

  /// Clear the session
  void clearSession() {
    _cooldowns.clear();
    emit(const SerialBarcodeScannerState(scannedItems: []));
  }
}
