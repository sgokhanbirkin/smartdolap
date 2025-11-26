import 'package:flutter/foundation.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_image_service.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';

/// Service responsible for fixing recipe image URLs
/// Follows Single Responsibility Principle - only handles image URL fixing
class RecipeImageService implements IRecipeImageService {
  RecipeImageService(this._imageLookup);

  final IImageLookupService _imageLookup;
  static final Map<String, String?> _queryCache = <String, String?>{};

  /// Fix image URL if it's invalid or missing
  /// [imageSearchQuery] is the English search query from AI (preferred over title)
  @override
  Future<String?> fixImageUrl(
    String? imageUrl,
    String title, {
    String? imageSearchQuery,
  }) async {
    // OpenAI'den gelen imageUrl'ler genelde çalışmıyor,
    // ImageLookupService kullan
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.contains('example.com') ||
        imageUrl.startsWith('http://example.com') ||
        imageUrl.startsWith('https://example.com')) {
      try {
        // ✅ ÖNCE AI'den gelen imageSearchQuery'yi kullan (Pexels/Unsplash için optimize edilmiş)
        // Eğer yoksa title'dan optimize edilmiş query oluştur
        final String searchQuery = imageSearchQuery?.isNotEmpty == true
            ? imageSearchQuery!
            : _optimizeImageQuery(title);

        debugPrint(
          '[RecipeImageService] Görsel arama sorgusu: "$searchQuery" '
          '${imageSearchQuery != null ? "(AI'den)" : "(title'dan optimize edildi)"}',
        );

        final String cacheKey = searchQuery.toLowerCase();
        if (_queryCache.containsKey(cacheKey)) {
          final String? cachedUrl = _queryCache[cacheKey];
          debugPrint(
            '[RecipeImageService] Görsel arama cache sonucu: ${cachedUrl ?? "NULL"}',
          );
          return cachedUrl;
        }

        final String? searchedImageUrl = await _imageLookup.search(searchQuery);
        _queryCache[cacheKey] = searchedImageUrl;
        if (_queryCache.length > 200) {
          _queryCache.remove(_queryCache.keys.first);
        }
        debugPrint(
          '[RecipeImageService] Görsel arama sonucu: ${searchedImageUrl ?? "NULL"}',
        );
        return searchedImageUrl;
      } on Exception catch (e) {
        debugPrint('[RecipeImageService] Görsel arama hatası: $e');
        return null;
      }
    }
    return imageUrl;
  }

  /// Optimize image search query to get better food images
  /// Adds food-related keywords and removes restaurant/shop related terms
  String _optimizeImageQuery(String title) {
    // Add food-related keywords to improve search results
    // This helps Google Images return actual food photos instead of restaurant photos
    const String foodKeywords = 'yemek tarifi food recipe';

    // Remove common restaurant-related words if present
    String optimized = title;
    final List<String> restaurantWords = <String>[
      'restoran',
      'restaurant',
      'cafe',
      'kafe',
      'menü',
      'menu',
    ];

    for (final String word in restaurantWords) {
      optimized = optimized.replaceAll(RegExp(word, caseSensitive: false), '');
    }

    // Combine title with food keywords
    return '$optimized $foodKeywords'.trim();
  }

  @override
  Future<List<T>> fixImageUrls<T extends Object>(
    List<T> recipes,
    String Function(T) getTitle,
    String? Function(T) getImageUrl,
    T Function(T, String?) updateImageUrl, {
    String? Function(T)? getImageSearchQuery,
  }) async {
    final List<T> result = <T>[];
    for (final T recipe in recipes) {
      final String? imageUrl = getImageUrl(recipe);
      if (imageUrl == null ||
          imageUrl.isEmpty ||
          imageUrl.contains('example.com')) {
        // Rate limiting önlemek için kısa bir bekleme ekle
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final String? imageSearchQuery = getImageSearchQuery?.call(recipe);
        final String? fixedImageUrl = await fixImageUrl(
          imageUrl,
          getTitle(recipe),
          imageSearchQuery: imageSearchQuery,
        );
        result.add(updateImageUrl(recipe, fixedImageUrl));
      } else {
        result.add(recipe);
      }
    }
    return result;
  }
}
