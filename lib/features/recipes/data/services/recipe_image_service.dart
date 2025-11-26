import 'package:flutter/foundation.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_image_service.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';

/// Service responsible for fixing recipe image URLs.
/// Currently acts as a no-op to avoid external image lookups in production.
class RecipeImageService implements IRecipeImageService {
  RecipeImageService(IImageLookupService _);

  /// Fix image URL if it's invalid or missing
  /// [imageSearchQuery] is the English search query from AI (preferred over title)
  @override
  Future<String?> fixImageUrl(
    String? imageUrl,
    String title, {
    String? imageSearchQuery,
  }) async {
    // PRODUCTION NOTE:
    // External image search is temporarily disabled for stability and
    // performance. For now we only use the existing URL (if any) and never
    // call external providers.
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.contains('example.com') ||
        imageUrl.startsWith('http://example.com') ||
        imageUrl.startsWith('https://example.com')) {
      // Görsel arama KAPALI: her zaman null döndür (placeholder kullanılacak).
      debugPrint(
        '[RecipeImageService] Image lookup disabled - returning null for "$title"',
      );
      return null;
    }
    return imageUrl;
  }

  @override
  Future<List<T>> fixImageUrls<T extends Object>(
    List<T> recipes,
    String Function(T) getTitle,
    String? Function(T) getImageUrl,
    T Function(T, String?) updateImageUrl, {
    String? Function(T)? getImageSearchQuery,
  }) async =>
      // Image lookup currently disabled - return recipes as-is.
      recipes;
}
