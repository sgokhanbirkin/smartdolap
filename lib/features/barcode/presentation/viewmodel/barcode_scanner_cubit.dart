// ignore_for_file: public_member_api_docs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/domain/repositories/i_product_lookup_repository.dart';
import 'package:smartdolap/features/barcode/domain/use_cases/scan_product_barcode_usecase.dart';
import 'package:smartdolap/features/barcode/presentation/viewmodel/barcode_scanner_state.dart';

/// Cubit for managing barcode scanner state
/// Follows MVVM pattern - business logic separated from UI
/// 
/// Responsibilities:
/// - Coordinate barcode scanning flow
/// - Handle scan results and errors
/// - Emit appropriate states for UI
class BarcodeScannerCubit extends Cubit<BarcodeScannerState> {
  final ScanProductBarcodeUseCase _scanProductUseCase;

  BarcodeScannerCubit(this._scanProductUseCase)
      : super(const BarcodeScannerState.ready());

  /// Handle a detected barcode
  /// 
  /// This is called when the camera detects a barcode
  /// Debouncing is handled in the UI layer
  Future<void> onBarcodeDetected(String barcode) async {
    Logger.info('[BarcodeScannerCubit] Barcode detected: $barcode');

    // Emit scanning state
    emit(BarcodeScannerState.scanning(barcode: barcode));

    try {
      // Execute use case
      final ScannedProduct? product = await _scanProductUseCase(barcode);

      if (product != null) {
        // Product found
        Logger.info(
          '[BarcodeScannerCubit] Product found: ${product.name}',
        );
        emit(BarcodeScannerState.productFound(product: product));
      } else {
        // Product not found
        Logger.info(
          '[BarcodeScannerCubit] Product not found for barcode: $barcode',
        );
        emit(BarcodeScannerState.productNotFound(barcode: barcode));
      }
    } on InvalidBarcodeException catch (e, stackTrace) {
      Logger.error(
        '[BarcodeScannerCubit] Invalid barcode',
        e,
        stackTrace,
      );
      emit(
        BarcodeScannerState.error(
          message: 'invalid_barcode',
          barcode: barcode,
        ),
      );
    } on NetworkException catch (e, stackTrace) {
      Logger.error(
        '[BarcodeScannerCubit] Network error',
        e,
        stackTrace,
      );
      emit(
        BarcodeScannerState.error(
          message: 'network_error',
          barcode: barcode,
        ),
      );
    } on RateLimitException catch (e, stackTrace) {
      Logger.error(
        '[BarcodeScannerCubit] Rate limit exceeded',
        e,
        stackTrace,
      );
      emit(
        BarcodeScannerState.error(
          message: 'rate_limit_exceeded',
          barcode: barcode,
        ),
      );
    } on Object catch (error, stackTrace) {
      Logger.error(
        '[BarcodeScannerCubit] Unexpected error',
        error,
        stackTrace,
      );
      emit(
        BarcodeScannerState.error(
          message: 'unknown_error',
          barcode: barcode,
        ),
      );
    }
  }

  /// Reset to ready state
  /// 
  /// Called after handling a scan result or dismissing an error
  void reset() {
    Logger.info('[BarcodeScannerCubit] Resetting to ready state');
    emit(const BarcodeScannerState.ready());
  }

  /// Handle camera permission denied
  void onPermissionDenied() {
    Logger.warning('[BarcodeScannerCubit] Camera permission denied');
    emit(const BarcodeScannerState.permissionDenied());
  }
}

