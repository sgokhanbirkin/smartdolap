// ignore_for_file: public_member_api_docs

import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/data/models/scan_result.dart';
import 'package:smartdolap/features/barcode/data/services/open_food_facts_service.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/domain/repositories/i_product_lookup_repository.dart';

/// Implementation of product lookup repository using OpenFoodFacts
/// Follows Dependency Inversion Principle (DIP)
///
/// This repository is responsible for:
/// 1. Coordinating with OpenFoodFacts service
/// 2. Converting between data models and domain entities
/// 3. Handling caching (future enhancement)
/// 4. Error handling and logging
class ProductLookupRepositoryImpl implements IProductLookupRepository {
  ProductLookupRepositoryImpl(this._service);
  final OpenFoodFactsService _service;

  @override
  String get sourceName => 'OpenFoodFacts';

  @override
  Future<ScannedProduct?> lookupByBarcode(String barcode) async {
    Logger.info('[ProductLookupRepository] Looking up barcode: $barcode');

    try {
      // 1. Fetch product from service
      final ScanResult result = await _service.lookupProduct(barcode);

      // 2. Convert to domain entity
      if (!result.isFound || result.product == null) {
        Logger.info('[ProductLookupRepository] Product not found: $barcode');
        return null;
      }

      final ScannedProduct product = result.product!.toEntity();

      Logger.info('[ProductLookupRepository] Product found: ${product.name}');

      // 3. TODO: Cache the result for offline access (future enhancement)
      // await _cacheService.cacheProduct(product);

      return product;
    } on NetworkException catch (e, stackTrace) {
      Logger.error('[ProductLookupRepository] Network error', e, stackTrace);
      rethrow;
    } on RateLimitException catch (e, stackTrace) {
      Logger.error(
        '[ProductLookupRepository] Rate limit exceeded',
        e,
        stackTrace,
      );
      rethrow;
    } on Object catch (error, stackTrace) {
      Logger.error(
        '[ProductLookupRepository] Unexpected error',
        error,
        stackTrace,
      );
      throw NetworkException('Failed to lookup product: $error');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _service.isAvailable();
    } on Object catch (error) {
      Logger.warning(
        '[ProductLookupRepository] Service availability check failed: $error',
      );
      return false;
    }
  }

  // Future enhancement: Add caching
  // Future<ScannedProduct?> _getCachedProduct(String barcode) async {
  //   return await _cacheService.getProduct(barcode);
  // }
}
