// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/rate_limiting/domain/entities/api_usage.dart';
import 'package:smartdolap/features/rate_limiting/domain/entities/package_type.dart';
import 'package:smartdolap/features/rate_limiting/domain/repositories/i_api_usage_repository.dart';

/// Firestore-based implementation for API usage repository
/// Follows SOLID principles:
/// - Single Responsibility: Only handles API usage data operations
/// - Dependency Inversion: Implements IApiUsageRepository interface
/// - Open/Closed: Open for extension, closed for modification
class ApiUsageRepositoryImpl implements IApiUsageRepository {
  ApiUsageRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _collection = 'api_usage';

  /// Get document reference for a user
  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection(_collection).doc(userId);

  @override
  Future<bool> canMakeRequest(String userId) async {
    try {
      final ApiUsage? usage = await getUsage(userId);
      if (usage == null) {
        // No usage record exists, allow request
        return true;
      }
      return usage.canMakeRequest();
    } catch (e) {
      Logger.error('[ApiUsageRepository] Error checking can make request', e);
      // Allow request on error to avoid blocking users
      return true;
    }
  }

  @override
  Future<void> incrementRequest(String userId) async {
    try {
      final DateTime now = DateTime.now();
      final DocumentReference<Map<String, dynamic>> docRef = _doc(userId);
      final DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

      if (!doc.exists) {
        // Create new usage record
        final ApiUsage newUsage = ApiUsage(
          userId: userId,
          packageType: PackageType.free,
          dailyRequestCount: 1,
          hourlyRequestCount: 1,
          lastRequestTime: now,
          resetDate: _getNextResetDate(now),
        );
        await docRef.set(newUsage.toJson());
        return;
      }

      // Update existing usage
      final Map<String, dynamic> data = doc.data()!;
      final DateTime? lastRequestTime = data['lastRequestTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastRequestTime'] as int)
          : null;
      final DateTime? resetDate = data['resetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['resetDate'] as int)
          : null;

      // Check if daily reset is needed
      final bool shouldResetDaily = resetDate != null && now.isAfter(resetDate);
      final int dailyCount = shouldResetDaily ? 1 : (data['dailyRequestCount'] as int? ?? 0) + 1;

      // Check if hourly reset is needed
      final bool shouldResetHourly = lastRequestTime != null &&
          now.difference(lastRequestTime).inHours >= 1;
      final int hourlyCount = shouldResetHourly ? 1 : (data['hourlyRequestCount'] as int? ?? 0) + 1;

      await docRef.update(<Object, Object?>{
        'dailyRequestCount': dailyCount,
        'hourlyRequestCount': hourlyCount,
        'lastRequestTime': now.millisecondsSinceEpoch,
        'resetDate': _getNextResetDate(now).millisecondsSinceEpoch,
      });
    } catch (e) {
      Logger.error('[ApiUsageRepository] Error incrementing request', e);
      rethrow;
    }
  }

  @override
  Future<ApiUsage?> getUsage(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return ApiUsage.fromJson(doc.data()!);
    } catch (e) {
      Logger.error('[ApiUsageRepository] Error getting usage', e);
      rethrow;
    }
  }

  @override
  Future<void> updatePackage(String userId, PackageType packageType) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef = _doc(userId);
      final DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

      if (!doc.exists) {
        // Create new usage record with new package
        final ApiUsage newUsage = ApiUsage(
          userId: userId,
          packageType: packageType,
          resetDate: _getNextResetDate(DateTime.now()),
        );
        await docRef.set(newUsage.toJson());
        return;
      }

      // Update package type and reset counters
      await docRef.update(<Object, Object?>{
        'packageType': packageType.name,
        'dailyRequestCount': 0,
        'hourlyRequestCount': 0,
        'resetDate': _getNextResetDate(DateTime.now()).millisecondsSinceEpoch,
      });
    } catch (e) {
      Logger.error('[ApiUsageRepository] Error updating package', e);
      rethrow;
    }
  }

  @override
  Future<void> resetDailyCounters(String userId) async {
    try {
      await _doc(userId).update(<Object, Object?>{
        'dailyRequestCount': 0,
        'resetDate': _getNextResetDate(DateTime.now()).millisecondsSinceEpoch,
      });
    } catch (e) {
      Logger.error('[ApiUsageRepository] Error resetting daily counters', e);
      rethrow;
    }
  }

  @override
  Future<void> resetHourlyCounters(String userId) async {
    try {
      await _doc(userId).update(<Object, Object?>{
        'hourlyRequestCount': 0,
      });
    } catch (e) {
      Logger.error('[ApiUsageRepository] Error resetting hourly counters', e);
      rethrow;
    }
  }

  /// Get next reset date (start of next day)
  DateTime _getNextResetDate(DateTime now) {
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }
}

