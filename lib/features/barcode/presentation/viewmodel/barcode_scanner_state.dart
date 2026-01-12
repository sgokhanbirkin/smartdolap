// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';

part 'barcode_scanner_state.freezed.dart';

/// States for barcode scanner feature
/// Using Freezed for immutability and union types
@freezed
class BarcodeScannerState with _$BarcodeScannerState {
  /// Initial state - ready to scan
  const factory BarcodeScannerState.ready() = _Ready;

  /// Scanning in progress
  const factory BarcodeScannerState.scanning({
    required String barcode,
  }) = _Scanning;

  /// Product found successfully
  const factory BarcodeScannerState.productFound({
    required ScannedProduct product,
  }) = _ProductFound;

  /// Product not found in database
  const factory BarcodeScannerState.productNotFound({
    required String barcode,
  }) = _ProductNotFound;

  /// Error occurred during scanning/lookup
  const factory BarcodeScannerState.error({
    required String message,
    String? barcode,
  }) = _Error;

  /// Camera permission denied
  const factory BarcodeScannerState.permissionDenied() = _PermissionDenied;
}

