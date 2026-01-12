// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartdolap/core/constants/api_constants.dart';
import 'package:smartdolap/core/utils/logger.dart';

/// Core API service for backend communication
/// Handles authentication, request/response interceptors, and error handling
class ApiService {
  ApiService(this._auth) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: <String, dynamic>{'Content-Type': 'application/json'},
      ),
    );

    // Add interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              try {
                // Get Firebase ID token
                final User? user = _auth.currentUser;
                if (user != null) {
                  final String? token = await user.getIdToken();
                  options.headers['Authorization'] = 'Bearer $token';
                  Logger.info('[ApiService] Added auth token to request');
                } else {
                  Logger.warning(
                    '[ApiService] No user logged in, skipping auth token',
                  );
                }
                return handler.next(options);
              } catch (e) {
                Logger.error(
                  '[ApiService] Failed to get auth token',
                  e,
                  StackTrace.current,
                );
                return handler.next(options);
              }
            },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
              Logger.info(
                '[ApiService] Response: ${response.statusCode} ${response.requestOptions.path}',
              );
              return handler.next(response);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          Logger.error(
            '[ApiService] Error: ${error.response?.statusCode} ${error.requestOptions.path}',
            error,
            StackTrace.current,
          );
          return handler.next(error);
        },
      ),
    );
  }
  late final Dio _dio;
  final FirebaseAuth _auth;

  /// Health check endpoint
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(ApiConstants.healthCheck);
      return response.data ?? <String, dynamic>{};
    } catch (e) {
      Logger.error('[ApiService] Health check failed', e, StackTrace.current);
      rethrow;
    }
  }

  /// Generate recipes from ingredients
  Future<List<Map<String, dynamic>>> generateRecipes({
    required List<String> ingredients,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .post<Map<String, dynamic>>(
            ApiConstants.generateRecipe,
            data: <String, Object>{
              'ingredients': ingredients,
              if (preferences != null) 'preferences': preferences,
            },
          );

      if (response.data?['success'] == true) {
        final List<dynamic> recipesData =
            response.data!['data']['recipes'] as List;
        return recipesData.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          response.data?['error'] ?? 'Failed to generate recipes',
        );
      }
    } catch (e) {
      Logger.error(
        '[ApiService] Recipe generation failed',
        e,
        StackTrace.current,
      );
      rethrow;
    }
  }

  /// Unified barcode scan - calls backend /scan/:barcode
  /// Returns ScanResult with product data or needsUserInput flag
  Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    try {
      Logger.info('[ApiService] Scanning barcode: $barcode');
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>('${ApiConstants.scanBarcode}/$barcode');

      Logger.info('[ApiService] Scan response: ${response.data}');
      return response.data ?? <String, dynamic>{'success': false};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Product not found - return needsUserInput flag
        Logger.info('[ApiService] Product not found (404): $barcode');
        return <String, dynamic>{
          'success': false,
          'source': null,
          'product': null,
          'needsUserInput': true,
        };
      }
      Logger.error('[ApiService] Scan failed', e, StackTrace.current);
      return <String, dynamic>{'success': false, 'error': e.message};
    }
  }

  /// Submit user-contributed product (crowdsourcing)
  Future<bool> submitProduct({
    required String barcode,
    required String name,
    String? brand,
    String? category,
    String? quantity,
  }) async {
    try {
      Logger.info('[ApiService] Submitting product: $barcode - $name');
      final Response<Map<String, dynamic>> response = await _dio
          .post<Map<String, dynamic>>(
            ApiConstants.submitProduct,
            data: <String, dynamic>{
              'barcode': barcode,
              'name': name,
              if (brand != null) 'brand': brand,
              if (category != null) 'category': category,
              if (quantity != null) 'quantity': quantity,
            },
          );

      if (response.data?['success'] == true) {
        Logger.info('[ApiService] Product submitted successfully: $barcode');
        return true;
      }
      return false;
    } on DioException catch (e) {
      Logger.error(
        '[ApiService] Product submission failed',
        e,
        StackTrace.current,
      );
      return false;
    }
  }

  /// Get Dio instance for custom requests
  Dio get dio => _dio;
}
