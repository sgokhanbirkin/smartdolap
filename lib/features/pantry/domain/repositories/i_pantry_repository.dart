// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Pantry repository contract — data source abstraction
/// Now uses householdId instead of userId for shared pantry
abstract class IPantryRepository {
  /// List all pantry items for a household
  Stream<List<PantryItem>> watchItems({required String householdId});

  /// Get current snapshot once
  Future<List<PantryItem>> getItems({required String householdId});

  /// Add item to household pantry
  Future<PantryItem> addItem({
    required String householdId,
    required PantryItem item,
  });

  /// Update item in household pantry
  Future<PantryItem> updateItem({
    required String householdId,
    required PantryItem item,
  });

  /// Delete item from household pantry
  Future<void> deleteItem({
    required String householdId,
    required String itemId,
  });
}
