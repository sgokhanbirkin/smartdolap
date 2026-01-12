import 'package:flutter/foundation.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_image_service.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';

/// Service responsible for fixing recipe image URLs using Pexels API.
/// Fetches high-quality food images when OpenAI doesn't provide valid URLs.
class RecipeImageService implements IRecipeImageService {
  RecipeImageService(this._imageLookupService);

  final IImageLookupService _imageLookupService;

  /// Fix image URL if it's invalid or missing
  /// [imageSearchQuery] is the English search query from AI (preferred over title)
  @override
  Future<String?> fixImageUrl(
    String? imageUrl,
    String title, {
    String? imageSearchQuery,
  }) async {
    // If we have a valid image URL, return it
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.contains('example.com') &&
        !imageUrl.startsWith('http://example.com') &&
        !imageUrl.startsWith('https://example.com')) {
      debugPrint(
        '[RecipeImageService] Using existing image URL for "$title"',
      );
      return imageUrl;
    }

    // If no valid URL, search for an image using Pexels
    debugPrint(
      '[RecipeImageService] Searching for image: query="${imageSearchQuery ?? title}"',
    );

    try {
      // Prefer AI-generated English search query for better results
      final String searchQuery = imageSearchQuery ?? title;
      final String? foundUrl = await _imageLookupService.search(searchQuery);

      if (foundUrl != null) {
        debugPrint(
          '[RecipeImageService] Found image for "$title": $foundUrl',
        );
        return foundUrl;
      } else {
        debugPrint(
          '[RecipeImageService] No image found for "$title" - will use placeholder',
        );
        return null;
      }
    } on Object catch (e) {
      debugPrint(
        '[RecipeImageService] Error searching for image "$title": $e',
      );
      return null;
    }
  }

  @override
  Future<List<T>> fixImageUrls<T extends Object>(
    List<T> recipes,
    String Function(T) getTitle,
    String? Function(T) getImageUrl,
    T Function(T, String?) updateImageUrl, {
    String? Function(T)? getImageSearchQuery,
  }) async {
    final List<T> fixedRecipes = <T>[];

    for (final T recipe in recipes) {
      final String? currentUrl = getImageUrl(recipe);
      final String? searchQuery = getImageSearchQuery?.call(recipe);
      final String? fixedUrl = await fixImageUrl(
        currentUrl,
        getTitle(recipe),
        imageSearchQuery: searchQuery,
      );

      fixedRecipes.add(updateImageUrl(recipe, fixedUrl));
    }

    return fixedRecipes;
  }
}
