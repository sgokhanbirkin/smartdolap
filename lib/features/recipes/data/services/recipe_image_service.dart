import 'package:flutter/foundation.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_image_service.dart';

/// Service responsible for fixing recipe image URLs
/// Follows Single Responsibility Principle - only handles image URL fixing
class RecipeImageService implements IRecipeImageService {
  RecipeImageService(this._imageLookup);

  final IImageLookupService _imageLookup;

  /// Fix image URL if it's invalid or missing
  Future<String?> fixImageUrl(String? imageUrl, String title) async {
    // OpenAI'den gelen imageUrl'ler genelde çalışmıyor,
    // ImageLookupService kullan
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.contains('example.com') ||
        imageUrl.startsWith('http://example.com') ||
        imageUrl.startsWith('https://example.com')) {
      try {
        // Optimize query for better food images (avoid restaurant/shop results)
        // Add food-related keywords to get better results
        final String optimizedQuery = _optimizeImageQuery(title);
        final String? searchedImageUrl = await _imageLookup.search(
          optimizedQuery,
        );
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
    final String foodKeywords = 'yemek tarifi food recipe';

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

  Future<List<T>> fixImageUrls<T extends Object>(
    List<T> recipes,
    String Function(T) getTitle,
    String? Function(T) getImageUrl,
    T Function(T, String?) updateImageUrl,
  ) async {
    return Future.wait(
      recipes.map((T recipe) async {
        final String? imageUrl = getImageUrl(recipe);
        if (imageUrl == null ||
            imageUrl.isEmpty ||
            imageUrl.contains('example.com')) {
          final String? fixedImageUrl = await fixImageUrl(
            imageUrl,
            getTitle(recipe),
          );
          return updateImageUrl(recipe, fixedImageUrl);
        }
        return recipe;
      }),
    );
  }
}
