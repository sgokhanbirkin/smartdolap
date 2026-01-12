// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';

/// Use case for bulk adding scanned products to pantry
/// Uses Firestore batch write for atomic operation
/// Checks for duplicates by name and merges quantities
class BulkAddPantryItems {
  BulkAddPantryItems(this._repository);

  final IPantryRepository _repository;

  /// Add multiple scanned products to pantry with specified quantities
  ///
  /// [products] - List of scanned products
  /// [quantities] - Map of barcode to quantity
  /// [userId] - Current user ID
  /// [householdId] - Current household ID
  ///
  /// Returns the number of items successfully added
  Future<int> call({
    required List<ScannedProduct> products,
    required Map<String, int> quantities,
    required String userId,
    required String householdId,
  }) async {
    if (products.isEmpty) {
      Logger.warning('[BulkAddPantryItems] No products to add');
      return 0;
    }

    Logger.info(
      '[BulkAddPantryItems] Adding ${products.length} items to pantry',
    );

    try {
      // Get existing items to check for duplicates
      final List<PantryItem> existingItems = await _repository.getItems(
        householdId: householdId,
      );
      final Map<String, PantryItem> existingItemsByName = {
        for (final item in existingItems) item.name.toLowerCase().trim(): item,
      };

      final batch = FirebaseFirestore.instance.batch();
      final pantryRef = FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('pantry');

      int addedCount = 0;
      int mergedCount = 0;

      for (final product in products) {
        final quantity = quantities[product.barcode] ?? 1;
        final String normalizedName = product.name.toLowerCase().trim();

        // Check if item with same name already exists
        final PantryItem? existingItem = existingItemsByName[normalizedName];

        if (existingItem != null) {
          // Merge: Update existing item quantity
          final double newQuantity =
              existingItem.quantity + quantity.toDouble();
          final PantryItem updatedItem = existingItem.copyWith(
            quantity: newQuantity,
            updatedAt: DateTime.now(),
          );

          final Map<String, dynamic> data = {
            'quantity': updatedItem.quantity,
            'updatedAt': Timestamp.fromDate(updatedItem.updatedAt!),
          };

          batch.update(pantryRef.doc(existingItem.id), data);
          mergedCount++;

          Logger.info(
            '[BulkAddPantryItems] Merged ${product.name}: '
            '${existingItem.quantity} + $quantity = $newQuantity',
          );
        } else {
          // New item: Create new document
          final PantryItem pantryItem = PantryItem(
            id: '', // Will be auto-generated
            name: product.name,
            quantity: quantity.toDouble(),
            unit: 'pcs', // Default unit
            category: product.category ?? 'other',
            expiryDate: null, // User can set later
            imageUrl: product.imageUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            addedByUserId: userId,
          );

          final docRef = pantryRef.doc();

          batch.set(docRef, {
            'id': docRef.id,
            'name': pantryItem.name,
            'quantity': pantryItem.quantity,
            'unit': pantryItem.unit,
            'category': pantryItem.category,
            'expiryDate': pantryItem.expiryDate,
            'imageUrl': pantryItem.imageUrl,
            'createdAt': pantryItem.createdAt != null
                ? Timestamp.fromDate(pantryItem.createdAt!)
                : FieldValue.serverTimestamp(),
            'updatedAt': pantryItem.updatedAt != null
                ? Timestamp.fromDate(pantryItem.updatedAt!)
                : FieldValue.serverTimestamp(),
            'addedByUserId': pantryItem.addedByUserId,
          });

          addedCount++;
        }
      }

      // Commit batch
      await batch.commit();

      Logger.info(
        '[BulkAddPantryItems] Successfully processed: '
        '$addedCount new, $mergedCount merged',
      );

      return addedCount + mergedCount;
    } catch (e, stackTrace) {
      Logger.error('[BulkAddPantryItems] Failed to add items', e, stackTrace);
      rethrow;
    }
  }
}
