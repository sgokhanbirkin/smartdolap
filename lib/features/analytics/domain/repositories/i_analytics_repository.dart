import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';

/// Repository interface for user analytics
/// Follows Dependency Inversion Principle (DIP)
abstract class IAnalyticsRepository {
  /// Calculate analytics for a user
  Future<UserAnalytics> calculateAnalytics({
    required String userId,
    required String householdId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get cached analytics
  Future<UserAnalytics?> getCachedAnalytics({
    required String userId,
    required String householdId,
  });

  /// Update analytics cache
  Future<void> updateAnalytics(UserAnalytics analytics);

  /// Watch analytics as a stream
  Stream<UserAnalytics> watchAnalytics({
    required String userId,
    required String householdId,
  });
}
