import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';

/// Service responsible for fixing recipe image URLs
/// Follows Single Responsibility Principle - only handles image URL fixing
class RecipeImageService {
  RecipeImageService(this._imageLookup);

  final ImageLookupService _imageLookup;

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
        final String? searchedImageUrl = await _imageLookup.search(
          '$title ${tr('recipe_search_suffix')}',
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

  /// Fix image URLs for multiple recipes
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

