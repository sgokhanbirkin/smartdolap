/// Interface for fixing recipe image URLs
/// Follows Dependency Inversion Principle (DIP)
abstract class IRecipeImageService {
  /// Fix image URL if it's invalid or missing
  /// [imageSearchQuery] is the English search query from AI (preferred over title)
  Future<String?> fixImageUrl(
    String? imageUrl,
    String title, {
    String? imageSearchQuery,
  });

  /// Fix image URLs for a list of recipes
  Future<List<T>> fixImageUrls<T extends Object>(
    List<T> recipes,
    String Function(T) getTitle,
    String? Function(T) getImageUrl,
    T Function(T, String?) updateImageUrl, {
    String? Function(T)? getImageSearchQuery,
  });
}
