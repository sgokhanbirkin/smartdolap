// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

/// Storage service interface for image/file uploads
abstract class IStorageService {
  /// Uploads an image for a user recipe
  /// Returns the download URL
  Future<String> uploadRecipePhoto({
    required String userId,
    required String recipeId,
    required Uint8List imageBytes,
    String? fileName,
  });

  /// Uploads an image for a pantry item
  /// Returns the download URL
  Future<String> uploadPantryItemPhoto({
    required String userId,
    required String itemId,
    required Uint8List imageBytes,
    String? fileName,
  });

  /// Uploads a general user image (e.g., dish photo)
  /// Returns the download URL
  Future<String> uploadUserImage({
    required String userId,
    required Uint8List imageBytes,
    required String folder,
    String? fileName,
  });

  /// Deletes an image from storage
  Future<void> deleteImage(String path);

  /// Gets download URL for an existing image
  Future<String?> getDownloadUrl(String path);
}

