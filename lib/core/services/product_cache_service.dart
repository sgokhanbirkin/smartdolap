// ignore_for_file: public_member_api_docs

import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';

/// In-memory cache for product lookup results
/// Reduces network calls for frequently scanned products
class ProductCacheService {
  ProductCacheService({Duration? ttl})
    : _ttl = ttl ?? const Duration(minutes: 30);
  final Map<String, _CachedProduct> _cache = <String, _CachedProduct>{};
  final Duration _ttl;

  /// Get product from cache if available and not expired
  ScannedProduct? get(String barcode) {
    final _CachedProduct? cached = _cache[barcode];
    if (cached != null && !cached.isExpired(_ttl)) {
      Logger.info('[ProductCache] HIT: $barcode');
      return cached.product;
    }
    if (cached != null) {
      Logger.info('[ProductCache] EXPIRED: $barcode');
      _cache.remove(barcode);
    } else {
      Logger.info('[ProductCache] MISS: $barcode');
    }
    return null;
  }

  /// Store product in cache
  void set(String barcode, ScannedProduct product) {
    _cache[barcode] = _CachedProduct(product, DateTime.now());
    Logger.info('[ProductCache] STORED: $barcode (total: ${_cache.length})');
  }

  /// Clear all cached products
  void clear() {
    final int count = _cache.length;
    _cache.clear();
    Logger.info('[ProductCache] CLEARED: $count products');
  }

  /// Get current cache size
  int get size => _cache.length;

  /// Get cache statistics
  Map<String, dynamic> get stats => <String, dynamic>{
    'size': _cache.length,
    'ttl_minutes': _ttl.inMinutes,
  };
}

/// Internal cached product wrapper
class _CachedProduct {
  _CachedProduct(this.product, this.cachedAt);
  final ScannedProduct product;
  final DateTime cachedAt;

  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;
}
