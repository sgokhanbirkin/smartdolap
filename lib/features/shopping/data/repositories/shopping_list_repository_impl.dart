import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';
import 'package:uuid/uuid.dart';

/// Firestore implementation for shopping list repository
class ShoppingListRepositoryImpl implements IShoppingListRepository {
  ShoppingListRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _households = 'households';
  static const String _shoppingList = 'shoppingList';
  static const Uuid _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _col(String householdId) =>
      _firestore
          .collection(_households)
          .doc(householdId)
          .collection(_shoppingList);

  @override
  Stream<List<ShoppingListItem>> watchItems({required String householdId}) {
    return _col(householdId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return ShoppingListItem.fromJson(data);
          }).toList();
        });
  }

  @override
  Future<List<ShoppingListItem>> getItems({required String householdId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _col(
        householdId,
      ).orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((
        QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return ShoppingListItem.fromJson(data);
      }).toList();
    } catch (e) {
      Logger.error('[ShoppingListRepository] Error getting items', e);
      rethrow;
    }
  }

  @override
  Future<ShoppingListItem> addItem({
    required String householdId,
    required ShoppingListItem item,
  }) async {
    try {
      final String itemId = item.id.isEmpty ? _uuid.v4() : item.id;
      final ShoppingListItem itemWithId = item.copyWith(id: itemId);

      await _col(householdId).doc(itemId).set(itemWithId.toJson());

      Logger.info('[ShoppingListRepository] Added item: ${itemWithId.name}');
      return itemWithId;
    } catch (e) {
      Logger.error('[ShoppingListRepository] Error adding item', e);
      rethrow;
    }
  }

  @override
  Future<ShoppingListItem> updateItem({
    required String householdId,
    required ShoppingListItem item,
  }) async {
    try {
      final ShoppingListItem updatedItem = item.copyWith(
        updatedAt: DateTime.now(),
      );

      await _col(householdId).doc(item.id).update(updatedItem.toJson());

      Logger.info('[ShoppingListRepository] Updated item: ${updatedItem.name}');
      return updatedItem;
    } catch (e) {
      Logger.error('[ShoppingListRepository] Error updating item', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteItem({
    required String householdId,
    required String itemId,
  }) async {
    try {
      await _col(householdId).doc(itemId).delete();
      Logger.info('[ShoppingListRepository] Deleted item: $itemId');
    } catch (e) {
      Logger.error('[ShoppingListRepository] Error deleting item', e);
      rethrow;
    }
  }

  @override
  Future<ShoppingListItem> completeItem({
    required String householdId,
    required String itemId,
    required String completedByUserId,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _col(
        householdId,
      ).doc(itemId).get();

      if (!snapshot.exists) {
        throw Exception('Shopping list item not found: $itemId');
      }

      final Map<String, dynamic> data = snapshot.data()!;
      data['id'] = snapshot.id;
      final ShoppingListItem currentItem = ShoppingListItem.fromJson(data);

      final ShoppingListItem completedItem = currentItem.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        completedByUserId: completedByUserId,
        updatedAt: DateTime.now(),
      );

      await _col(householdId).doc(itemId).update(completedItem.toJson());

      Logger.info(
        '[ShoppingListRepository] Completed item: ${completedItem.name}',
      );
      return completedItem;
    } catch (e) {
      Logger.error('[ShoppingListRepository] Error completing item', e);
      rethrow;
    }
  }
}
