// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, unnecessary_parenthesis, unnecessary_lambdas, avoid_annotating_with_dynamic, always_specify_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:uuid/uuid.dart';

/// Firestore-based implementation for Pantry repository
class PantryRepositoryImpl implements IPantryRepository {
  PantryRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _users = 'users';
  static const String _pantry = 'pantry';
  static const Uuid _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection(_users).doc(userId).collection(_pantry);

  @override
  Stream<List<PantryItem>> watchItems({required String userId}) => _col(userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => _fromDoc(d))
            .toList(),
      );

  @override
  Future<List<PantryItem>> getItems({required String userId}) async {
    final QuerySnapshot<Map<String, dynamic>> q = await _col(
      userId,
    ).orderBy('createdAt', descending: true).get();
    return q.docs.map(_fromDoc).toList();
  }

  @override
  Future<PantryItem> addItem({
    required String userId,
    required PantryItem item,
  }) async {
    final String id = item.id.isEmpty ? _uuid.v4() : item.id;
    final DateTime now = DateTime.now();
    final Map<String, dynamic> data = _toMap(
      item,
    ).map((String k, dynamic v) => MapEntry(k, v));
    data['id'] = id;
    data['createdAt'] = now.toIso8601String();
    data['updatedAt'] = now.toIso8601String();
    await _col(userId).doc(id).set(data);
    return item.copyWith(id: id, createdAt: now, updatedAt: now);
  }

  @override
  Future<PantryItem> updateItem({
    required String userId,
    required PantryItem item,
  }) async {
    final DateTime now = DateTime.now();
    final Map<String, dynamic> data = _toMap(item);
    data['updatedAt'] = now.toIso8601String();
    await _col(userId).doc(item.id).update(data);
    return item.copyWith(updatedAt: now);
  }

  @override
  Future<void> deleteItem({required String userId, required String itemId}) =>
      _col(userId).doc(itemId).delete();

  PantryItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final Map<String, dynamic> m = d.data();
    return PantryItem(
      id: m['id'] as String? ?? d.id,
      name: m['name'] as String? ?? '',
      quantity: (m['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: m['unit'] as String? ?? '',
      expiryDate: m['expiryDate'] != null
          ? DateTime.tryParse(m['expiryDate'] as String)
          : null,
      ingredients:
          (m['ingredients'] as List<dynamic>?)
              ?.map(
                (dynamic e) => Ingredient(
                  name: (e as Map<String, dynamic>)['name'] as String? ?? '',
                  unit: (e)['unit'] as String? ?? '',
                  quantity: ((e)['quantity'] as num?)?.toDouble() ?? 1.0,
                ),
              )
              .toList() ??
          const <Ingredient>[],
      createdAt: m['createdAt'] != null
          ? DateTime.tryParse(m['createdAt'] as String)
          : null,
      updatedAt: m['updatedAt'] != null
          ? DateTime.tryParse(m['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> _toMap(PantryItem item) => <String, dynamic>{
    'id': item.id,
    'name': item.name,
    'quantity': item.quantity,
    'unit': item.unit,
    'expiryDate': item.expiryDate?.toIso8601String(),
    'ingredients': item.ingredients
        .map(
          (Ingredient i) => <String, dynamic>{
            'name': i.name,
            'unit': i.unit,
            'quantity': i.quantity,
          },
        )
        .toList(),
    'createdAt': item.createdAt?.toIso8601String(),
    'updatedAt': item.updatedAt?.toIso8601String(),
  };
}
