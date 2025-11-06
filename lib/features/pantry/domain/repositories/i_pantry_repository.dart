// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Pantry repository contract — data source abstraction
abstract class IPantryRepository {
  /// List all pantry items for a user
  Stream<List<PantryItem>> watchItems({required String userId});

  /// Get current snapshot once
  Future<List<PantryItem>> getItems({required String userId});

  /// Add item
  Future<PantryItem> addItem({
    required String userId,
    required PantryItem item,
  });

  /// Update item
  Future<PantryItem> updateItem({
    required String userId,
    required PantryItem item,
  });

  /// Delete item
  Future<void> deleteItem({required String userId, required String itemId});
}
