// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';

/// Repository interface for product barcode lookup
/// Follows Dependency Inversion Principle (DIP)
///
/// This interface defines the contract for looking up products by barcode.
/// Multiple implementations can exist (OpenFoodFacts, local DB, etc.)
abstract class IProductLookupRepository {
  /// Look up a product by its barcode
  ///
  /// Returns [ScannedProduct] if found, null otherwise
  ///
  /// Throws:
  /// - [NetworkException] if network error occurs
  /// - [RateLimitException] if rate limit exceeded
  Future<ScannedProduct?> lookupByBarcode(String barcode);

  /// Check if the service is available
  ///
  /// Returns true if the lookup service can be used
  Future<bool> isAvailable();

  /// Get the name of the data source
  ///
  /// Returns a human-readable name (e.g., "OpenFoodFacts")
  String get sourceName;
}

/// Exception thrown when network error occurs during lookup
class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when rate limit is exceeded
class RateLimitException implements Exception {
  RateLimitException(this.message, {this.retryAfter});
  final String message;
  final Duration? retryAfter;

  @override
  String toString() => 'RateLimitException: $message';
}

/// Exception thrown when barcode format is invalid
class InvalidBarcodeException implements Exception {
  InvalidBarcodeException(this.message, this.barcode);
  final String message;
  final String barcode;

  @override
  String toString() => 'InvalidBarcodeException: $message (barcode: $barcode)';
}
