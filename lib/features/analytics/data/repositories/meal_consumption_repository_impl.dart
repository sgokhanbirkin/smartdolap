import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/analytics/domain/entities/meal_consumption.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_meal_consumption_repository.dart';

/// Firestore implementation for meal consumption repository
class MealConsumptionRepositoryImpl implements IMealConsumptionRepository {
  MealConsumptionRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _households = 'households';
  static const String _mealConsumptions = 'mealConsumptions';

  CollectionReference<Map<String, dynamic>> _col(String householdId) =>
      _firestore
          .collection(_households)
          .doc(householdId)
          .collection(_mealConsumptions);

  @override
  Future<void> recordConsumption(MealConsumption consumption) async {
    try {
      await _col(
        consumption.householdId,
      ).doc(consumption.id).set(consumption.toJson());
      Logger.info(
        '[MealConsumptionRepository] Recorded consumption: ${consumption.recipeTitle}',
      );
    } catch (e) {
      Logger.error(
        '[MealConsumptionRepository] Error recording consumption',
        e,
      );
      rethrow;
    }
  }

  @override
  Stream<List<MealConsumption>> watchConsumptions({
    required String householdId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query<Map<String, dynamic>> query = _col(householdId);

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    if (startDate != null) {
      query = query.where('consumedAt', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('consumedAt', isLessThanOrEqualTo: endDate);
    }

    query = query.orderBy('consumedAt', descending: true);

    return query.snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) => snapshot.docs.map((
        QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return MealConsumption.fromJson(data);
      }).toList());
  }

  @override
  Future<List<MealConsumption>> getConsumptions({
    required String householdId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _col(householdId);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (startDate != null) {
        query = query.where('consumedAt', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('consumedAt', isLessThanOrEqualTo: endDate);
      }

      query = query.orderBy('consumedAt', descending: true);

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      return snapshot.docs.map((
        QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return MealConsumption.fromJson(data);
      }).toList();
    } catch (e) {
      Logger.error('[MealConsumptionRepository] Error getting consumptions', e);
      rethrow;
    }
  }
}
