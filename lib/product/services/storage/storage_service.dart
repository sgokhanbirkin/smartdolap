// ignore_for_file: public_member_api_docs, avoid_catches_without_on_clauses

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartdolap/product/services/storage/i_storage_service.dart';
import 'package:uuid/uuid.dart';

/// Firebase Storage implementation
class StorageService implements IStorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;
  static const Uuid _uuid = Uuid();

  String _generatePath({
    required String userId,
    required String folder,
    String? fileName,
  }) {
    final String uniqueFileName = fileName ?? '${_uuid.v4()}.jpg';
    return 'users/$userId/$folder/$uniqueFileName';
  }

  @override
  Future<String> uploadRecipePhoto({
    required String userId,
    required String recipeId,
    required Uint8List imageBytes,
    String? fileName,
  }) => uploadUserImage(
    userId: userId,
    imageBytes: imageBytes,
    folder: 'recipes',
    fileName: fileName ?? '$recipeId.jpg',
  );

  @override
  Future<String> uploadPantryItemPhoto({
    required String userId,
    required String itemId,
    required Uint8List imageBytes,
    String? fileName,
  }) => uploadUserImage(
    userId: userId,
    imageBytes: imageBytes,
    folder: 'pantry',
    fileName: fileName ?? '$itemId.jpg',
  );

  @override
  Future<String> uploadUserImage({
    required String userId,
    required Uint8List imageBytes,
    required String folder,
    String? fileName,
  }) async {
    final String path = _generatePath(
      userId: userId,
      folder: folder,
      fileName: fileName,
    );

    try {
      final Reference ref = _storage.ref(path);
      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException('Failed to upload image: ${e.message}');
    } catch (e) {
      throw StorageException('Failed to upload image: $e');
    }
  }

  @override
  Future<void> deleteImage(String path) async {
    try {
      final Reference ref = _storage.ref(path);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException('Failed to delete image: ${e.message}');
    } catch (e) {
      throw StorageException('Failed to delete image: $e');
    }
  }

  @override
  Future<String?> getDownloadUrl(String path) async {
    try {
      final Reference ref = _storage.ref(path);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}

/// Storage-related exceptions
class StorageException implements Exception {
  StorageException(this.message);
  final String message;
  @override
  String toString() => 'StorageException: $message';
}
