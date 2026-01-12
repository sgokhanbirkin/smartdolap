import 'dart:async';
import 'dart:collection';

import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/domain/use_cases/scan_product_barcode_usecase.dart';

/// Status of a queued scan item
enum ScanStatus {
  /// Item is waiting to be processed
  pending,

  /// Item is currently being processed
  processing,

  /// Item was successfully processed
  found,

  /// Item was not found in the database
  notFound,

  /// Item processing failed with an error
  error,
}

/// Represents a queued barcode scan with its current status
class QueuedScan {
  /// Constructor
  QueuedScan({
    required this.barcode,
    required this.timestamp,
    this.status = ScanStatus.pending,
    this.product,
    this.errorMessage,
  });

  /// The barcode string
  final String barcode;

  /// When the barcode was scanned
  final DateTime timestamp;

  /// Current status of the scan
  ScanStatus status;

  /// The product if found
  ScannedProduct? product;

  /// Error message if failed
  String? errorMessage;

  /// Create a copy with updated fields
  QueuedScan copyWith({
    String? barcode,
    DateTime? timestamp,
    ScanStatus? status,
    ScannedProduct? product,
    String? errorMessage,
  }) =>
      QueuedScan(
        barcode: barcode ?? this.barcode,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
        product: product ?? this.product,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

/// Manages a queue of barcode scans for non-blocking, serial processing
/// Provides instant UI feedback while processing items in the background
class ScanQueueManager {
  /// Constructor
  ScanQueueManager(this._scanProductUseCase);

  final ScanProductBarcodeUseCase _scanProductUseCase;

  /// Internal queue of scans
  final Queue<QueuedScan> _queue = Queue<QueuedScan>();

  /// All scans (both pending and processed) for UI display
  final List<QueuedScan> _allScans = <QueuedScan>[];

  /// Whether the manager is currently processing
  bool _isProcessing = false;

  /// Cooldown tracking: Barcode -> Last Scanned Time
  final Map<String, DateTime> _cooldowns = <String, DateTime>{};

  /// Cooldown duration to prevent duplicate scans
  static const Duration cooldownDuration = Duration(seconds: 2);

  /// Stream controller for scan updates
  final StreamController<List<QueuedScan>> _scanUpdatesController =
      StreamController<List<QueuedScan>>.broadcast();

  /// Stream controller for status updates (for audio/haptic feedback)
  final StreamController<QueuedScan> _statusUpdatesController =
      StreamController<QueuedScan>.broadcast();

  /// Stream of all scans (for UI updates)
  Stream<List<QueuedScan>> get scanUpdates => _scanUpdatesController.stream;

  /// Stream of individual status updates (for feedback)
  Stream<QueuedScan> get statusUpdates => _statusUpdatesController.stream;

  /// Get current list of all scans
  List<QueuedScan> get allScans => List<QueuedScan>.unmodifiable(_allScans);

  /// Get count of pending scans
  int get pendingCount =>
      _allScans.where((QueuedScan s) => s.status == ScanStatus.pending).length;

  /// Get count of successfully found products
  int get foundCount =>
      _allScans.where((QueuedScan s) => s.status == ScanStatus.found).length;

  /// Add a barcode to the queue
  /// Returns true if added, false if cooldown is active
  bool addBarcode(String barcode) {
    // Check cooldown
    final DateTime now = DateTime.now();
    if (_cooldowns.containsKey(barcode)) {
      final DateTime lastScanned = _cooldowns[barcode]!;
      if (now.difference(lastScanned) < cooldownDuration) {
        Logger.info(
          '[ScanQueueManager] Barcode $barcode is in cooldown, ignoring',
        );
        return false;
      }
    }

    // Update cooldown
    _cooldowns[barcode] = now;

    // Create queued scan
    final QueuedScan scan = QueuedScan(
      barcode: barcode,
      timestamp: now,
      status: ScanStatus.pending,
    );

    // Add to queue and all scans
    _queue.add(scan);
    _allScans.insert(0, scan); // Add to top for display

    Logger.info('[ScanQueueManager] Added barcode $barcode to queue');

    // Emit update
    _scanUpdatesController.add(List<QueuedScan>.from(_allScans));

    // Start processing if not already running
    if (!_isProcessing) {
      _processQueue();
    }

    return true;
  }

  /// Process the queue sequentially
  Future<void> _processQueue() async {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final QueuedScan scan = _queue.removeFirst();

      // Update status to processing
      scan.status = ScanStatus.processing;
      _scanUpdatesController.add(List<QueuedScan>.from(_allScans));
      _statusUpdatesController.add(scan);

      try {
        Logger.info('[ScanQueueManager] Processing barcode: ${scan.barcode}');
        final ScannedProduct? product =
            await _scanProductUseCase(scan.barcode);

        if (product != null) {
          // Product found
          scan
            ..status = ScanStatus.found
            ..product = product;
          Logger.info(
            '[ScanQueueManager] Product found: ${product.name}',
          );
        } else {
          // Product not found
          scan.status = ScanStatus.notFound;
          Logger.info(
            '[ScanQueueManager] Product not found for: ${scan.barcode}',
          );
        }
      } on Object catch (error, stackTrace) {
        // Error occurred
        scan
          ..status = ScanStatus.error
          ..errorMessage = error.toString();
        Logger.error(
          '[ScanQueueManager] Error processing ${scan.barcode}',
          error,
          stackTrace,
        );
      }

      // Emit updates
      _scanUpdatesController.add(List<QueuedScan>.from(_allScans));
      _statusUpdatesController.add(scan);

      // Small delay between scans to avoid overwhelming the API
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    _isProcessing = false;
  }

  /// Remove a scan at the given index
  void removeScan(int index) {
    if (index >= 0 && index < _allScans.length) {
      final QueuedScan removed = _allScans.removeAt(index);
      Logger.info('[ScanQueueManager] Removed scan: ${removed.barcode}');
      _scanUpdatesController.add(List<QueuedScan>.from(_allScans));
    }
  }

  /// Clear all scans and reset the queue
  void clear() {
    _queue.clear();
    _allScans.clear();
    _cooldowns.clear();
    Logger.info('[ScanQueueManager] Cleared all scans');
    _scanUpdatesController.add(<QueuedScan>[]);
  }

  /// Get only successfully found products
  List<ScannedProduct> getFoundProducts() => _allScans
      .where(
        (QueuedScan s) => s.status == ScanStatus.found && s.product != null,
      )
      .map((QueuedScan s) => s.product!)
      .toList();

  /// Dispose and clean up resources
  void dispose() {
    _scanUpdatesController.close();
    _statusUpdatesController.close();
  }
}
