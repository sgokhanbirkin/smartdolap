// ignore_for_file: public_member_api_docs

import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/domain/repositories/i_product_lookup_repository.dart';

/// Use case for scanning product barcode and looking up product information
/// Follows Single Responsibility Principle (SRP)
///
/// This use case orchestrates the barcode scanning flow:
/// 1. Validate barcode format
/// 2. Look up product from repository
/// 3. Handle errors appropriately
class ScanProductBarcodeUseCase {
  ScanProductBarcodeUseCase(this._repository);
  final IProductLookupRepository _repository;

  /// Execute the use case
  ///
  /// [barcode] - The scanned barcode string
  ///
  /// Returns [ScannedProduct] if found and valid, null otherwise
  ///
  /// Throws:
  /// - [InvalidBarcodeException] if barcode format is invalid
  /// - [NetworkException] if network error occurs
  /// - [RateLimitException] if rate limit exceeded
  Future<ScannedProduct?> call(String barcode) async {
    Logger.info('[ScanProductBarcodeUseCase] Scanning barcode: $barcode');

    // 1. Validate barcode format
    _validateBarcode(barcode);

    // 2. Check if lookup service is available
    // Optimization: Skip strict connectivity check and try lookup directly
    /*
    final bool isAvailable = await _repository.isAvailable();
    if (!isAvailable) {
      Logger.warning(
        '[ScanProductBarcodeUseCase] Lookup service not available',
      );
      throw NetworkException('Product lookup service is not available');
    }
    */

    // 3. Look up product
    try {
      final ScannedProduct? product = await _repository.lookupByBarcode(
        barcode,
      );

      if (product != null) {
        Logger.info(
          '[ScanProductBarcodeUseCase] Product found: ${product.name}',
        );
      } else {
        Logger.info(
          '[ScanProductBarcodeUseCase] Product not found for barcode: $barcode',
        );
      }

      return product;
    } on NetworkException catch (e, stackTrace) {
      Logger.error(
        '[ScanProductBarcodeUseCase] Network error during lookup',
        e,
        stackTrace,
      );
      rethrow;
    } on RateLimitException catch (e, stackTrace) {
      Logger.error(
        '[ScanProductBarcodeUseCase] Rate limit exceeded',
        e,
        stackTrace,
      );
      rethrow;
    } on Object catch (error, stackTrace) {
      Logger.error(
        '[ScanProductBarcodeUseCase] Unexpected error during lookup',
        error,
        stackTrace,
      );
      throw NetworkException('Failed to lookup product: $error');
    }
  }

  /// Validate barcode format
  ///
  /// Supports common formats: EAN-13, EAN-8, UPC-A, UPC-E
  ///
  /// Throws [InvalidBarcodeException] if format is invalid
  void _validateBarcode(String barcode) {
    // Remove whitespace
    final String cleaned = barcode.trim();

    // Check if empty
    if (cleaned.isEmpty) {
      throw InvalidBarcodeException('Barcode cannot be empty', barcode);
    }

    // Check if contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      throw InvalidBarcodeException(
        'Barcode must contain only digits',
        barcode,
      );
    }

    // Check length (EAN-8: 8, UPC-E: 8, EAN-13: 13, UPC-A: 12)
    final int length = cleaned.length;
    if (length != 8 && length != 12 && length != 13) {
      throw InvalidBarcodeException(
        'Invalid barcode length (expected 8, 12, or 13 digits)',
        barcode,
      );
    }
  }
}
