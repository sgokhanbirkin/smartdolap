// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, unnecessary_parenthesis, unnecessary_lambdas, avoid_annotating_with_dynamic, always_specify_types

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:uuid/uuid.dart';

/// Firestore-based implementation for Pantry repository
class PantryRepositoryImpl implements IPantryRepository {
  PantryRepositoryImpl(this._firestore, this._cache);

  final FirebaseFirestore _firestore;
  final Box<dynamic> _cache;
  static const String _users = 'users';
  static const String _pantry = 'pantry';
  static const Uuid _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection(_users).doc(userId).collection(_pantry);

  @override
  Stream<List<PantryItem>> watchItems({required String userId}) {
    final StreamController<List<PantryItem>> controller =
        StreamController<List<PantryItem>>();
    final List<PantryItem> cached = _readCache(userId);
    if (cached.isNotEmpty) {
      controller.add(cached);
    }

    final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> sub =
        _col(userId).orderBy('createdAt', descending: true).snapshots().listen((
          QuerySnapshot<Map<String, dynamic>> snap,
        ) {
          final List<PantryItem> items = snap.docs
              .map(_fromDoc)
              .toList(growable: false);
          _writeCache(userId, items);
          controller.add(items);
        }, onError: controller.addError);

    controller.onCancel = () async {
      await sub.cancel();
      await controller.close();
    };
    return controller.stream;
  }

  @override
  Future<List<PantryItem>> getItems({required String userId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> q = await _col(
        userId,
      ).orderBy('createdAt', descending: true).get();
      final List<PantryItem> items = q.docs
          .map(_fromDoc)
          .toList(growable: false);
      _writeCache(userId, items);
      return items;
    } catch (e) {
      final List<PantryItem> cached = _readCache(userId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
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
    final PantryItem created = item.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
    _cacheInsert(userId, created);
    return created;
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
    final PantryItem updated = item.copyWith(updatedAt: now);
    _cacheUpsert(userId, updated);
    return updated;
  }

  @override
  Future<void> deleteItem({
    required String userId,
    required String itemId,
  }) async {
    await _col(userId).doc(itemId).delete();
    _cacheRemove(userId, itemId);
  }

  PantryItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
      _fromMap(d.data(), fallbackId: d.id);

  PantryItem _fromMap(Map<String, dynamic> m, {String? fallbackId}) => PantryItem(
    id: m['id'] as String? ?? fallbackId ?? '',
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
    category: m['category'] as String?,
    createdAt: m['createdAt'] != null
        ? DateTime.tryParse(m['createdAt'] as String)
        : null,
    updatedAt: m['updatedAt'] != null
        ? DateTime.tryParse(m['updatedAt'] as String)
        : null,
  );

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
    'category': item.category,
    'createdAt': item.createdAt?.toIso8601String(),
    'updatedAt': item.updatedAt?.toIso8601String(),
  };

  List<PantryItem> _readCache(String userId) {
    final List<dynamic>? raw = _cache.get(userId) as List<dynamic>?;
    if (raw == null) {
      return <PantryItem>[];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> map) =>
              _fromMap(Map<String, dynamic>.from(map)),
        )
        .toList(growable: true);
  }

  void _writeCache(String userId, List<PantryItem> items) {
    _cache.put(userId, items.map(_toMap).toList(growable: false));
  }

  void _cacheInsert(String userId, PantryItem item) {
    final List<PantryItem> current = _readCache(userId);
    current.removeWhere((PantryItem e) => e.id == item.id);
    current.insert(0, item);
    _writeCache(userId, current);
  }

  void _cacheUpsert(String userId, PantryItem item) {
    final List<PantryItem> current = _readCache(userId);
    final int idx = current.indexWhere((PantryItem e) => e.id == item.id);
    if (idx >= 0) {
      current[idx] = item;
    } else {
      current.insert(0, item);
    }
    _writeCache(userId, current);
  }

  void _cacheRemove(String userId, String itemId) {
    final List<PantryItem> current = _readCache(userId);
    current.removeWhere((PantryItem e) => e.id == itemId);
    _writeCache(userId, current);
  }
}
