// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/domain/services/scan_queue_manager.dart';
import 'package:smartdolap/features/barcode/domain/use_cases/scan_product_barcode_usecase.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/serial_barcode_scanner_state_v2.dart';

/// Cubit for managing serial barcode scanner with queue-based processing
class SerialBarcodeScannerCubitV2
    extends Cubit<SerialBarcodeScannerStateV2> {
  SerialBarcodeScannerCubitV2(this._scanProductUseCase)
      : super(const SerialBarcodeScannerStateV2()) {
    _queueManager = ScanQueueManager(_scanProductUseCase);
    _setupListeners();
  }

  final ScanProductBarcodeUseCase _scanProductUseCase;
  late final ScanQueueManager _queueManager;
  StreamSubscription<List<QueuedScan>>? _scanUpdatesSubscription;
  StreamSubscription<QueuedScan>? _statusUpdatesSubscription;

  /// Setup listeners for queue updates
  void _setupListeners() {
    // Listen to scan list updates
    _scanUpdatesSubscription = _queueManager.scanUpdates.listen(
      (List<QueuedScan> scans) {
        emit(
          state.copyWith(
            queuedScans: scans,
            pendingCount: _queueManager.pendingCount,
            foundCount: _queueManager.foundCount,
          ),
        );
      },
    );

    // Listen to status updates for feedback triggers
    _statusUpdatesSubscription = _queueManager.statusUpdates.listen(
      (QueuedScan scan) {
        Logger.info(
          '[SerialBarcodeScannerCubitV2] Status update: ${scan.barcode} -> ${scan.status}',
        );

        // Emit feedback event based on status
        switch (scan.status) {
          case ScanStatus.found:
            emit(state.copyWith(lastFeedbackEvent: FeedbackEvent.success));
            break;
          case ScanStatus.notFound:
            emit(
              state.copyWith(
                lastFeedbackEvent: FeedbackEvent.notFound,
                lastErrorBarcode: scan.barcode,
              ),
            );
            break;
          case ScanStatus.error:
            emit(
              state.copyWith(
                lastFeedbackEvent: FeedbackEvent.error,
                lastErrorMessage: scan.errorMessage,
              ),
            );
            break;
          case ScanStatus.pending:
          case ScanStatus.processing:
            // No special feedback for these statuses
            break;
        }
      },
    );
  }

  /// Handle a detected barcode - adds to queue immediately
  /// Returns true if added, false if in cooldown
  bool onBarcodeDetected(String barcode) {
    Logger.info(
      '[SerialBarcodeScannerCubitV2] Barcode detected: $barcode',
    );

    final bool added = _queueManager.addBarcode(barcode);

    if (added) {
      // Emit scan detected event for immediate haptic/audio feedback
      emit(state.copyWith(lastFeedbackEvent: FeedbackEvent.scanDetected));
    }

    return added;
  }

  /// Remove a scan from the list
  void removeScan(int index) {
    _queueManager.removeScan(index);
  }

  /// Clear the entire session
  void clearSession() {
    _queueManager.clear();
  }

  /// Get only successfully found products (for passing to review page)
  List<ScannedProduct> getFoundProducts() =>
      _queueManager.getFoundProducts();

  @override
  Future<void> close() {
    _scanUpdatesSubscription?.cancel();
    _statusUpdatesSubscription?.cancel();
    _queueManager.dispose();
    return super.close();
  }
}
