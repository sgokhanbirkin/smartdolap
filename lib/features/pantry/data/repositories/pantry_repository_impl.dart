// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, unnecessary_parenthesis, unnecessary_lambdas, avoid_annotating_with_dynamic, always_specify_types

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:uuid/uuid.dart';

/// Firestore-based implementation for Pantry repository
/// Now uses households/{householdId}/pantry instead of users/{userId}/pantry
class PantryRepositoryImpl implements IPantryRepository {
  PantryRepositoryImpl(this._firestore, this._cache);

  final FirebaseFirestore _firestore;
  final Box<dynamic> _cache;
  static const String _households = 'households';
  static const String _pantry = 'pantry';
  static const Uuid _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _col(String householdId) =>
      _firestore.collection(_households).doc(householdId).collection(_pantry);

  @override
  Stream<List<PantryItem>> watchItems({required String householdId}) {
    final StreamController<List<PantryItem>> controller =
        StreamController<List<PantryItem>>();
    final List<PantryItem> cached = _readCache(householdId);
    if (cached.isNotEmpty) {
      controller.add(cached);
    }

    final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> sub =
        _col(householdId).orderBy('createdAt', descending: true).snapshots().listen((
          QuerySnapshot<Map<String, dynamic>> snap,
        ) {
          final List<PantryItem> items = snap.docs
              .map(_fromDoc)
              .toList(growable: false);
          _writeCache(householdId, items);
          controller.add(items);
        }, onError: controller.addError);

    controller.onCancel = () async {
      await sub.cancel();
      await controller.close();
    };
    return controller.stream;
  }

  @override
  Future<List<PantryItem>> getItems({required String householdId}) async {
    // 1. Önce Hive cache'den kontrol et
    final List<PantryItem> cached = _readCache(householdId);
    if (cached.isNotEmpty) {
      // Cache'de veri varsa önce onu döndür, sonra arka planda Firestore'dan güncelle
      _syncFromFirestoreInBackground(householdId);
      return cached;
    }

    // 2. Cache boşsa Firestore'dan çek
    try {
      final QuerySnapshot<Map<String, dynamic>> q = await _col(
        householdId,
      ).orderBy('createdAt', descending: true).get();
      final List<PantryItem> items = q.docs
          .map(_fromDoc)
          .toList(growable: false);
      _writeCache(householdId, items);
      return items;
    } catch (e) {
      // Firestore hatası durumunda cache'i kontrol et (fallback)
      final List<PantryItem> cached = _readCache(householdId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  /// Syncs from Firestore in background without blocking
  void _syncFromFirestoreInBackground(String householdId) {
    _col(householdId).orderBy('createdAt', descending: true).get().then((
      QuerySnapshot<Map<String, dynamic>> q,
    ) {
      final List<PantryItem> items = q.docs
          .map(_fromDoc)
          .toList(growable: false);
      _writeCache(householdId, items);
    }).catchError((dynamic e) {
      // Silently fail - cache is already available
    });
  }

  @override
  Future<PantryItem> addItem({
    required String householdId,
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
    await _col(householdId).doc(id).set(data);
    final PantryItem created = item.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
    _cacheInsert(householdId, created);
    return created;
  }

  @override
  Future<PantryItem> updateItem({
    required String householdId,
    required PantryItem item,
  }) async {
    final DateTime now = DateTime.now();
    final Map<String, dynamic> data = _toMap(item);
    data['updatedAt'] = now.toIso8601String();
    await _col(householdId).doc(item.id).update(data);
    final PantryItem updated = item.copyWith(updatedAt: now);
    _cacheUpsert(householdId, updated);
    return updated;
  }

  @override
  Future<void> deleteItem({
    required String householdId,
    required String itemId,
  }) async {
    await _col(householdId).doc(itemId).delete();
    _cacheRemove(householdId, itemId);
  }

  PantryItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
      _fromMap(d.data(), fallbackId: d.id);

  /// Helper method to parse DateTime from Firestore
  /// Handles both Timestamp (from Firestore) and String (from cache) types
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  PantryItem _fromMap(Map<String, dynamic> m, {String? fallbackId}) => PantryItem(
    id: m['id'] as String? ?? fallbackId ?? '',
    name: m['name'] as String? ?? '',
    quantity: (m['quantity'] as num?)?.toDouble() ?? 1.0,
    unit: m['unit'] as String? ?? '',
    expiryDate: _parseDateTime(m['expiryDate']),
    imageUrl: m['imageUrl'] as String?,
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
    createdAt: _parseDateTime(m['createdAt']),
    updatedAt: _parseDateTime(m['updatedAt']),
    addedByUserId: m['addedByUserId'] as String?,
    addedByAvatarId: m['addedByAvatarId'] as String?,
  );

  Map<String, dynamic> _toMap(PantryItem item) => <String, dynamic>{
    'id': item.id,
    'name': item.name,
    'quantity': item.quantity,
    'unit': item.unit,
    'expiryDate': item.expiryDate?.toIso8601String(),
    'imageUrl': item.imageUrl,
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
    'addedByUserId': item.addedByUserId,
    'addedByAvatarId': item.addedByAvatarId,
  };

  List<PantryItem> _readCache(String householdId) {
    final List<dynamic>? raw = _cache.get(householdId) as List<dynamic>?;
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

  void _writeCache(String householdId, List<PantryItem> items) {
    _cache.put(householdId, items.map(_toMap).toList(growable: false));
  }

  void _cacheInsert(String householdId, PantryItem item) {
    final List<PantryItem> current = _readCache(householdId);
    current.removeWhere((PantryItem e) => e.id == item.id);
    current.insert(0, item);
    _writeCache(householdId, current);
  }

  void _cacheUpsert(String householdId, PantryItem item) {
    final List<PantryItem> current = _readCache(householdId);
    final int idx = current.indexWhere((PantryItem e) => e.id == item.id);
    if (idx >= 0) {
      current[idx] = item;
    } else {
      current.insert(0, item);
    }
    _writeCache(householdId, current);
  }

  void _cacheRemove(String householdId, String itemId) {
    final List<PantryItem> current = _readCache(householdId);
    current.removeWhere((PantryItem e) => e.id == itemId);
    _writeCache(householdId, current);
  }
}
