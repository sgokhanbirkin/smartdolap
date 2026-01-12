import 'package:dio/dio.dart';
import 'package:smartdolap/core/services/api_service.dart';
import 'package:smartdolap/core/services/product_cache_service.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/data/models/product_model.dart';
import 'package:smartdolap/features/barcode/data/models/scan_result.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/domain/repositories/i_product_lookup_repository.dart';

/// Service for product barcode lookup
///
/// Uses unified backend /scan/:barcode endpoint
/// Backend handles all fallback logic (cache → Turkish DB → OpenFoodFacts)
///
/// If backend is unavailable, falls back to direct OpenFoodFacts API
class OpenFoodFactsService {
  OpenFoodFactsService({
    ApiService? apiService,
    ProductCacheService? productCache,
    Dio? dio,
  }) : _apiService = apiService,
       _productCache = productCache,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: _baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
               headers: <String, String>{
                 'User-Agent': _userAgent,
                 'Accept': 'application/json',
               },
             ),
           );
  final ApiService? _apiService;
  final ProductCacheService? _productCache;
  final Dio _dio;

  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0';
  static const String _userAgent = 'SmartDolap/1.0 (pantry management app)';

  /// Look up a product by barcode
  ///
  /// UNIFIED Strategy:
  /// 1. Check memory cache (instant)
  /// 2. Call backend /scan/:barcode (handles all sources)
  /// 3. Fallback to direct OpenFoodFacts if backend unavailable
  ///
  /// Returns [ScanResult] with product or needsUserInput flag
  Future<ScanResult> lookupProduct(String barcode) async {
    Logger.info('[OpenFoodFactsService] Looking up barcode: $barcode');

    // Step 1: Check memory cache
    if (_productCache != null) {
      final ScannedProduct? cached = _productCache.get(barcode);
      if (cached != null) {
        Logger.info('[OpenFoodFactsService] Cache HIT: $barcode');
        return ScanResult.found(
          product: ProductModel.fromEntity(cached),
          source: 'cache',
        );
      }
    }

    // Step 2: Try unified backend scan API
    if (_apiService != null) {
      try {
        Logger.info('[OpenFoodFactsService] Calling backend /scan: $barcode');
        final Map<String, dynamic> response = await _apiService.scanBarcode(
          barcode,
        );

        if (response['success'] == true && response['product'] != null) {
          final ProductModel product = ProductModel.fromJson(
            response['product'] as Map<String, dynamic>,
          );

          // Cache the result
          if (_productCache != null) {
            _productCache.set(barcode, product.toEntity());
          }

          Logger.info(
            '[OpenFoodFactsService] Backend SUCCESS: $barcode (source: ${response['source']})',
          );
          return ScanResult.found(
            product: product,
            source: response['source'] as String? ?? 'backend',
          );
        }

        // Check if backend says we need user input (crowdsourcing)
        if (response['needsUserInput'] == true) {
          Logger.info(
            '[OpenFoodFactsService] Product not found, needs user input: $barcode',
          );
          return ScanResult.needsUserInput(barcode: barcode);
        }
      } catch (e) {
        Logger.warning('[OpenFoodFactsService] Backend failed: $e');
        // Continue to direct OpenFoodFacts fallback
      }
    }

    // Step 3: Fallback to direct OpenFoodFacts API
    Logger.info('[OpenFoodFactsService] Trying direct OpenFoodFacts: $barcode');
    final ProductModel? directResult = await _lookupProductDirect(barcode);
    if (directResult != null) {
      Logger.info('[OpenFoodFactsService] OpenFoodFacts SUCCESS: $barcode');
      return ScanResult.found(product: directResult, source: 'openfoodfacts');
    }

    Logger.info('[OpenFoodFactsService] Product not found: $barcode');
    return ScanResult.needsUserInput(barcode: barcode);
  }

  /// Legacy method for backward compatibility - returns ProductModel or null
  Future<ProductModel?> lookupProductLegacy(String barcode) async {
    final ScanResult result = await lookupProduct(barcode);
    return result.product;
  }

  /// Direct lookup from OpenFoodFacts API (fallback method)
  Future<ProductModel?> _lookupProductDirect(String barcode) async {
    Logger.info('[OpenFoodFactsService] Direct API lookup: $barcode');

    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>('/product/$barcode.json');

      // Check if product was found
      final int? status = response.data?['status'] as int?;

      if (status == null) {
        throw NetworkException('Invalid API response structure');
      }

      if (status == 0) {
        // Product not found
        Logger.info('[OpenFoodFactsService] Product not found: $barcode');
        return null;
      }

      if (status == 1) {
        // Product found
        Logger.info('[OpenFoodFactsService] Product found: $barcode');

        final ProductModel product = ProductModel.fromOpenFoodFactsJson(
          response.data!,
          barcode,
        );

        // Cache the result
        if (_productCache != null) {
          _productCache.set(barcode, product.toEntity());
        }

        return product;
      }

      throw NetworkException('Unexpected status code: $status');
    } on DioException catch (error, stackTrace) {
      Logger.error(
        '[OpenFoodFactsService] Dio error during lookup',
        error,
        stackTrace,
      );

      // Handle specific error cases
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout - check your internet');
      }

      if (error.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      }

      if (error.response?.statusCode == 429) {
        throw RateLimitException(
          'Rate limit exceeded - please try again later',
          retryAfter: const Duration(minutes: 1),
        );
      }

      if (error.response?.statusCode == 503) {
        throw NetworkException('Service temporarily unavailable');
      }

      // 404 means product not found - return null instead of throwing
      if (error.response?.statusCode == 404) {
        Logger.info('[OpenFoodFactsService] Product not found (404): $barcode');
        return null;
      }

      throw NetworkException('Failed to lookup product: ${error.message}');
    } on FormatException catch (error, stackTrace) {
      Logger.error(
        '[OpenFoodFactsService] Format error parsing response',
        error,
        stackTrace,
      );
      throw NetworkException('Invalid product data format');
    } on Object catch (error, stackTrace) {
      Logger.error(
        '[OpenFoodFactsService] Unexpected error',
        error,
        stackTrace,
      );
      throw NetworkException('Unexpected error: $error');
    }
  }

  /// Check if OpenFoodFacts API is available
  ///
  /// Returns true if API is reachable
  Future<bool> isAvailable() async {
    try {
      // Try to ping the API with a known valid barcode (Coca-Cola)
      final Response<dynamic> response = await _dio.get(
        '/product/5449000000996.json',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );

      return response.statusCode == 200;
    } on Object catch (error) {
      Logger.warning('[OpenFoodFactsService] API not available: $error');
      return false;
    }
  }

  /// Search products by name (for future use)
  ///
  /// This can be used to implement a search feature
  Future<List<ProductModel>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    Logger.info('[OpenFoodFactsService] Searching products: $query');

    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(
            '/cgi/search.pl',
            queryParameters: <String, dynamic>{
              'search_terms': query,
              'page': page,
              'page_size': pageSize,
              'json': 1,
            },
          );

      final List<dynamic>? products =
          response.data?['products'] as List<dynamic>?;

      if (products == null || products.isEmpty) {
        return <ProductModel>[];
      }

      return products
          .whereType<Map<String, dynamic>>()
          .map<ProductModel?>((json) {
            final Map<String, dynamic> productJson = json;
            final String? code = productJson['code'] as String?;

            if (code == null) return null;

            try {
              return ProductModel.fromOpenFoodFactsJson(<String, dynamic>{
                'product': productJson,
              }, code);
            } on Object catch (e) {
              Logger.warning(
                '[OpenFoodFactsService] Failed to parse product: $e',
              );
              return null;
            }
          })
          .whereType<ProductModel>()
          .toList();
    } on DioException catch (error, stackTrace) {
      Logger.error(
        '[OpenFoodFactsService] Error during search',
        error,
        stackTrace,
      );
      throw NetworkException('Failed to search products: ${error.message}');
    }
  }
}
