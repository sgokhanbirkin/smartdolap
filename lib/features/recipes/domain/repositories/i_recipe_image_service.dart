/// Interface for fixing recipe image URLs
/// Follows Dependency Inversion Principle (DIP)
abstract class IRecipeImageService {
  /// Fix image URL if it's invalid or missing
  Future<String?> fixImageUrl(String? imageUrl, String title);

  /// Fix image URLs for a list of recipes
  Future<List<T>> fixImageUrls<T extends Object>(
    List<T> recipes,
    String Function(T) getTitle,
    String? Function(T) getImageUrl,
    T Function(T, String?) updateImageUrl,
  );
}
