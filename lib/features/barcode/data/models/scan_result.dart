import 'package:smartdolap/features/barcode/data/models/product_model.dart';

/// Result of a barcode scan operation
///
/// Contains either:
/// - A found product with source information
/// - A flag indicating user input is needed (crowdsourcing)
class ScanResult {
  const ScanResult._({
    this.product,
    this.source,
    this.needsUserInput = false,
    this.barcode,
    this.error,
  });

  /// Product was found successfully
  factory ScanResult.found({
    required ProductModel product,
    required String source,
  }) => ScanResult._(product: product, source: source);

  /// Product not found - needs user to submit product info
  factory ScanResult.needsUserInput({required String barcode}) =>
      ScanResult._(needsUserInput: true, barcode: barcode);

  /// An error occurred during scan
  factory ScanResult.error(String message) => ScanResult._(error: message);
  final ProductModel? product;
  final String? source;
  final bool needsUserInput;
  final String? barcode;
  final String? error;

  /// Whether the scan found a product
  bool get isFound => product != null;

  /// Whether an error occurred
  bool get isError => error != null;

  @override
  String toString() {
    if (isFound) {
      return 'ScanResult.found(product: ${product?.name}, source: $source)';
    } else if (needsUserInput) {
      return 'ScanResult.needsUserInput(barcode: $barcode)';
    } else if (isError) {
      return 'ScanResult.error($error)';
    }
    return 'ScanResult.unknown';
  }
}
