// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/barcode/domain/services/scan_queue_manager.dart';

part 'serial_barcode_scanner_state_v2.freezed.dart';

/// Feedback events for audio/haptic feedback
enum FeedbackEvent {
  /// Initial/no event
  none,

  /// Barcode was just scanned (immediate feedback)
  scanDetected,

  /// Product successfully found
  success,

  /// Product not found
  notFound,

  /// Error occurred
  error,
}

/// State for serial barcode scanner with queue-based processing
@freezed
class SerialBarcodeScannerStateV2 with _$SerialBarcodeScannerStateV2 {
  const factory SerialBarcodeScannerStateV2({
    /// List of all queued scans with their statuses
    @Default([]) List<QueuedScan> queuedScans,

    /// Count of pending scans
    @Default(0) int pendingCount,

    /// Count of successfully found products
    @Default(0) int foundCount,

    /// Last feedback event for triggering audio/haptic
    @Default(FeedbackEvent.none) FeedbackEvent lastFeedbackEvent,

    /// Last error barcode (for showing dialogs)
    String? lastErrorBarcode,

    /// Last error message
    String? lastErrorMessage,
  }) = _SerialBarcodeScannerStateV2;
}
