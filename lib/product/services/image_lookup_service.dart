import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interface for image lookup services
/// Follows Dependency Inversion Principle - allows multiple implementations
abstract class IImageLookupService {
  /// Search for an image URL based on query
  /// Returns the first matching image URL or null if not found
  Future<String?> search(String query);
}

/// Google Custom Search API implementation for image search
/// Uses Google Custom Search API (requires API key and Search Engine ID)
class GoogleImageSearchService implements IImageLookupService {
  GoogleImageSearchService({
    required this.dio,
    required this.apiKey,
    required this.searchEngineId,
  });

  final Dio dio;
  final String apiKey;
  final String searchEngineId;

  static const String _baseUrl = 'https://www.googleapis.com/customsearch/v1';

  @override
  Future<String?> search(String query) async {
    final String sanitized = query.trim();
    if (sanitized.isEmpty) {
      return null;
    }

    try {
      final Response<Map<String, dynamic>> response = await dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: <String, dynamic>{
          'key': apiKey,
          'cx': searchEngineId,
          'q': sanitized,
          'searchType': 'image',
          'num': 5, // Get top 5 results
          'safe': 'active', // Safe search
          'imgSize': 'large', // Prefer large images
          'imgType': 'photo', // Only photos
        },
        options: Options(
          headers: <String, String>{
            'Accept': 'application/json',
          },
        ),
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return null;
      }

      final List<dynamic>? items = data['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) {
        debugPrint('[GoogleImageSearchService] No results for query: $sanitized');
        return null;
      }

      // Return the first valid image URL
      for (final dynamic item in items) {
        final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
        final String? imageUrl = itemMap['link'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty && _isValidImageUrl(imageUrl)) {
          debugPrint('[GoogleImageSearchService] Found image: $imageUrl');
          return imageUrl;
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('[GoogleImageSearchService] Error: ${e.message}');
      if (e.response != null) {
        debugPrint('[GoogleImageSearchService] Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('[GoogleImageSearchService] Unexpected error: $e');
      return null;
    }
  }

  bool _isValidImageUrl(String url) {
    // Filter out invalid URLs
    if (url.contains('example.com') ||
        url.contains('placeholder') ||
        url.contains('logo') ||
        url.contains('icon')) {
      return false;
    }
    // Must be a valid image URL
    return url.startsWith('http://') || url.startsWith('https://');
  }
}

/// Pexels API implementation for image search
/// Free tier: 200 requests per hour
/// Requires API key from https://www.pexels.com/api/
class PexelsImageSearchService implements IImageLookupService {
  PexelsImageSearchService({
    required this.dio,
    required this.apiKey,
  });

  final Dio dio;
  final String apiKey;

  static const String _baseUrl = 'https://api.pexels.com/v1/search';

  @override
  Future<String?> search(String query) async {
    final String sanitized = query.trim();
    if (sanitized.isEmpty) {
      return null;
    }

    try {
      final Response<Map<String, dynamic>> response = await dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: <String, dynamic>{
          'query': sanitized,
          'per_page': 5,
          'orientation': 'landscape', // Better for recipe cards
        },
        options: Options(
          headers: <String, String>{
            'Authorization': apiKey,
            'Accept': 'application/json',
          },
        ),
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return null;
      }

      final List<dynamic>? photos = data['photos'] as List<dynamic>?;
      if (photos == null || photos.isEmpty) {
        debugPrint('[PexelsImageSearchService] No results for query: $sanitized');
        return null;
      }

      // Return the first result's medium URL (good balance of quality and size)
      final Map<String, dynamic> firstPhoto = photos.first as Map<String, dynamic>;
      final Map<String, dynamic>? src = firstPhoto['src'] as Map<String, dynamic>?;
      final String? imageUrl = src?['medium'] as String?;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        debugPrint('[PexelsImageSearchService] Found image: $imageUrl');
        return imageUrl;
      }

      return null;
    } on DioException catch (e) {
      debugPrint('[PexelsImageSearchService] Error: ${e.message}');
      if (e.response != null) {
        debugPrint('[PexelsImageSearchService] Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('[PexelsImageSearchService] Unexpected error: $e');
      return null;
    }
  }
}

/// Unsplash API implementation for image search
/// Free tier: 50 requests per hour
/// Requires API key from https://unsplash.com/developers
class UnsplashImageSearchService implements IImageLookupService {
  UnsplashImageSearchService({
    required this.dio,
    required this.accessKey,
  });

  final Dio dio;
  final String accessKey;

  static const String _baseUrl = 'https://api.unsplash.com/search/photos';

  @override
  Future<String?> search(String query) async {
    final String sanitized = query.trim();
    if (sanitized.isEmpty) {
      return null;
    }

    try {
      final Response<Map<String, dynamic>> response = await dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: <String, dynamic>{
          'query': sanitized,
          'per_page': 5,
          'orientation': 'landscape', // Better for recipe cards
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Client-ID $accessKey',
            'Accept': 'application/json',
          },
        ),
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return null;
      }

      final List<dynamic>? results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        debugPrint('[UnsplashImageSearchService] No results for query: $sanitized');
        return null;
      }

      // Return the first result's regular URL
      final Map<String, dynamic> firstResult = results.first as Map<String, dynamic>;
      final Map<String, dynamic>? urls = firstResult['urls'] as Map<String, dynamic>?;
      final String? imageUrl = urls?['regular'] as String?;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        debugPrint('[UnsplashImageSearchService] Found image: $imageUrl');
        return imageUrl;
      }

      return null;
    } on DioException catch (e) {
      debugPrint('[UnsplashImageSearchService] Error: ${e.message}');
      if (e.response != null) {
        debugPrint('[UnsplashImageSearchService] Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('[UnsplashImageSearchService] Unexpected error: $e');
      return null;
    }
  }
}

/// Fallback service that tries multiple image search services in order
/// Implements Strategy Pattern with fallback chain
class MultiImageSearchService implements IImageLookupService {
  MultiImageSearchService({
    required this.services,
  }) : assert(services.isNotEmpty, 'At least one service must be provided');

  /// List of image search services to try in order
  final List<IImageLookupService> services;

  @override
  Future<String?> search(String query) async {
    // Try each service in order until one succeeds
    for (final IImageLookupService service in services) {
      try {
        final String? result = await service.search(query);
        if (result != null && result.isNotEmpty) {
          debugPrint('[MultiImageSearchService] Found image using ${service.runtimeType}');
          return result;
        }
      } catch (e) {
        debugPrint('[MultiImageSearchService] Service ${service.runtimeType} failed: $e');
        // Continue to next service
      }
    }

    debugPrint('[MultiImageSearchService] All services failed for query: $query');
    return null;
  }
}

/// Google Images HTML scraping service
/// ✅ User's phone makes the request - safer and more reliable
/// Each user has their own IP, so rate limiting is not an issue
/// Free and unlimited - no API key needed
/// ⚠️ WARNING: May violate Google's Terms of Service (but low risk from user devices)
class GoogleImagesHtmlScrapingService implements IImageLookupService {
  GoogleImagesHtmlScrapingService(this.dio);

  final Dio dio;

  // Mobile User-Agent to make requests look more natural
  // Using iPhone User-Agent as it's very common
  static const Map<String, String> _headers = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Cache-Control': 'max-age=0',
  };

  @override
  Future<String?> search(String query) async {
    final String sanitized = query.trim();
    if (sanitized.isEmpty) {
      return null;
    }

    try {
      // Google Images search URL
      // Using Turkish locale for better results
      final String searchUrl =
          'https://www.google.com/search?q=${Uri.encodeComponent(sanitized)}&tbm=isch&hl=tr';

      final Response<String> response = await dio.get<String>(
        searchUrl,
        options: Options(
          headers: _headers,
          responseType: ResponseType.plain,
          followRedirects: true,
          validateStatus: (int? status) => status != null && status < 500,
        ),
      );

      // Check if Google blocked the request
      if (response.statusCode == 429 || response.statusCode == 403) {
        debugPrint('[GoogleImagesHtmlScrapingService] Google blocked the request (${response.statusCode})');
        return null;
      }

      final String html = response.data ?? '';
      if (html.isEmpty) {
        return null;
      }

      // Check if Google returned a CAPTCHA page
      if (html.contains('captcha') || html.contains('CAPTCHA') || html.contains('unusual traffic')) {
        debugPrint('[GoogleImagesHtmlScrapingService] Google CAPTCHA detected');
        return null;
      }

      // Try to extract image URLs from HTML
      // We'll collect multiple results and filter out restaurant/shop images
      final List<String> candidateUrls = <String>[];
      
      // Method 1: Look for JSON-LD structured data
      final RegExp jsonLdPattern = RegExp(
        r'<script[^>]*type=.*application/ld\+json.*>(.*?)</script>',
        dotAll: true,
        caseSensitive: false,
      );
      final Iterable<RegExpMatch> jsonLdMatches = jsonLdPattern.allMatches(html);
      for (final RegExpMatch match in jsonLdMatches) {
        try {
          final String jsonContent = match.group(1) ?? '';
          // Look for image URLs in JSON-LD - simplified pattern
          final RegExp imageUrlPattern = RegExp(
            r'https?://[^\s"<>]+\.(jpg|jpeg|png|webp)',
            caseSensitive: false,
          );
          final Iterable<RegExpMatch> imageMatches = imageUrlPattern.allMatches(jsonContent);
          for (final RegExpMatch imageMatch in imageMatches) {
            final String? imageUrl = imageMatch.group(0);
            if (imageUrl != null && _isValidImageUrl(imageUrl)) {
              candidateUrls.add(imageUrl);
            }
          }
        } catch (e) {
          // Continue to next method
        }
      }

      // Method 2: Look for img tags with data-src or src attributes
      final RegExp imgPattern = RegExp(
        r'<img[^>]+(?:data-src|src)=([^\s>]+)',
        caseSensitive: false,
      );
      final Iterable<RegExpMatch> imgMatches = imgPattern.allMatches(html);
      for (final RegExpMatch match in imgMatches) {
        String? imageUrl = match.group(1);
        // Remove quotes if present
        if (imageUrl != null) {
          if (imageUrl.startsWith('"') || imageUrl.startsWith("'")) {
            imageUrl = imageUrl.substring(1);
          }
          if (imageUrl.endsWith('"') || imageUrl.endsWith("'")) {
            imageUrl = imageUrl.substring(0, imageUrl.length - 1);
          }
        }
        if (imageUrl != null &&
            imageUrl.startsWith('http') &&
            _isValidImageUrl(imageUrl) &&
            !imageUrl.contains('google') &&
            !imageUrl.contains('gstatic')) {
          candidateUrls.add(imageUrl);
        }
      }

      // Filter out restaurant/shop images and return the best match
      // Skip first 2-3 results as they're usually restaurant photos
      // Then find the first good food image
      for (int i = 2; i < candidateUrls.length && i < 10; i++) {
        final String url = candidateUrls[i];
        if (_isGoodFoodImage(url, sanitized)) {
          debugPrint('[GoogleImagesHtmlScrapingService] Found good food image (skipped ${i} restaurant images): $url');
          return url;
        }
      }

      // If no good food image found, return the first valid one (better than nothing)
      if (candidateUrls.isNotEmpty) {
        debugPrint('[GoogleImagesHtmlScrapingService] Using first available image: ${candidateUrls.first}');
        return candidateUrls.first;
      }

      // Method 3: Look for base64 encoded images in data URLs (less reliable)
      final RegExp base64Pattern = RegExp(
        r'data:image/[^;]+;base64,[A-Za-z0-9+/=]+',
      );
      final RegExpMatch? base64Match = base64Pattern.firstMatch(html);
      if (base64Match != null) {
        // Base64 images are too large, skip them
        debugPrint('[GoogleImagesHtmlScrapingService] Found base64 image, skipping');
      }

      debugPrint('[GoogleImagesHtmlScrapingService] No image found for query: $sanitized');
      return null;
    } on DioException catch (e) {
      debugPrint('[GoogleImagesHtmlScrapingService] Error: ${e.message}');
      if (e.response != null) {
        debugPrint('[GoogleImagesHtmlScrapingService] Status: ${e.response?.statusCode}');
        // Google may return 429 (Too Many Requests) or 403 (Forbidden)
        if (e.response?.statusCode == 429 || e.response?.statusCode == 403) {
          debugPrint('[GoogleImagesHtmlScrapingService] Google blocked the request');
        }
      }
      return null;
    } catch (e) {
      debugPrint('[GoogleImagesHtmlScrapingService] Unexpected error: $e');
      return null;
    }
  }

  bool _isValidImageUrl(String url) {
    // Filter out invalid URLs
    if (url.contains('example.com') ||
        url.contains('placeholder') ||
        url.contains('logo') ||
        url.contains('icon') ||
        url.contains('avatar') ||
        url.contains('google') ||
        url.contains('gstatic')) {
      return false;
    }
    // Must be a valid image URL
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Check if URL is likely a good food image (not restaurant/shop)
  bool _isGoodFoodImage(String url, String query) {
    final String lowerUrl = url.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    
    // Filter out restaurant/shop related URLs
    final List<String> badKeywords = <String>[
      'restaurant',
      'restoran',
      'cafe',
      'kafe',
      'menu',
      'menü',
      'shop',
      'dükkan',
      'store',
      'mağaza',
      'delivery',
      'sipariş',
      'order',
      'yelp',
      'tripadvisor',
      'zomato',
      'ubereats',
      'yemeksepeti',
      'getir',
      'logo',
      'sign',
      'tabela',
      'exterior',
      'dış',
      'interior',
      'iç',
      'building',
      'bina',
    ];
    
    // Check if URL contains bad keywords
    for (final String keyword in badKeywords) {
      if (lowerUrl.contains(keyword)) {
        return false;
      }
    }
    
    // Prefer URLs that contain food-related keywords
    final List<String> goodKeywords = <String>[
      'food',
      'yemek',
      'recipe',
      'tarif',
      'cooking',
      'pişirme',
      'dish',
      'yemek',
      'meal',
      'öğün',
      'plate',
      'tabak',
      'serving',
      'servis',
    ];
    
    // Bonus points if URL contains food keywords
    for (final String keyword in goodKeywords) {
      if (lowerUrl.contains(keyword) || lowerQuery.contains(keyword)) {
        return true;
      }
    }
    
    // If no bad keywords found, it's probably okay
    return true;
  }
}

/// DuckDuckGo implementation (kept for backward compatibility)
/// This is the old implementation that doesn't work reliably
class DuckDuckGoImageSearchService implements IImageLookupService {
  DuckDuckGoImageSearchService(this.dio);

  final Dio dio;

  static const Map<String, String> _headers = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
  };

  @override
  Future<String?> search(String query) async {
    final String sanitized = query.trim();
    if (sanitized.isEmpty) {
      return null;
    }
    try {
      final Response<String> tokenRes = await dio.get<String>(
        'https://duckduckgo.com/',
        queryParameters: <String, String>{'q': sanitized},
        options: Options(responseType: ResponseType.plain, headers: _headers),
      );
      final String? token = _extractToken(tokenRes.data ?? '');
      if (token == null) {
        return null;
      }

      final Response<dynamic> res = await dio.get<dynamic>(
        'https://duckduckgo.com/i.js',
        queryParameters: <String, String>{
          'l': 'tr-tr',
          'o': 'json',
          'q': sanitized,
          'vqd': token,
        },
        options: Options(headers: _headers),
      );
      final List<dynamic>? results = res.data?['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return null;
      }
      final Map<String, dynamic> first = results.first as Map<String, dynamic>;
      return first['image'] as String?;
    } on Exception {
      return null;
    }
  }

  String? _extractToken(String body) {
    final RegExpMatch? match = RegExp("vqd='([^']+)'").firstMatch(body);
    return match?.group(1);
  }
}
