// ignore_for_file: public_member_api_docs

/// API constants for backend integration
class ApiConstants {
  // Backend API Base URL
  static const String baseUrl =
      'https://us-central1-smart-do-76854.cloudfunctions.net/api';

  // API Endpoints
  static const String healthCheck = '/health';
  static const String generateRecipe = '/api/ai/generateRecipe';

  // Unified Barcode Scan (replaces old getProduct and getTurkishProduct)
  static const String scanBarcode = '/scan'; // + /:barcode
  static const String submitProduct = '/product/submit'; // POST

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Private constructor to prevent instantiation
  ApiConstants._();
}
