// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';

part 'serial_barcode_scanner_state.freezed.dart';

/// States for serial barcode scanner feature
@freezed
class SerialBarcodeScannerState with _$SerialBarcodeScannerState {
  const factory SerialBarcodeScannerState({
    /// List of successfully scanned products in the current session
    @Default([]) List<ScannedProduct> scannedItems,

    /// Whether a product is currently being looked up
    @Default(false) bool isProcessing,

    /// Last scanned barcode (for immediate feedback logic if needed)
    String? lastScannedBarcode,

    /// Latest error message if any
    String? errorMessage,

    /// Trigger for "effect" (like a one-shot event for UI)
    /// We can use a timestamp or unique ID to signal a new event
    /// But sticking to simple state for now.
    ///
    /// Instead of complex event bus, we can just infer "success" if list grows.
  }) = _SerialBarcodeScannerState;
}
