import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_analytics_repository.dart';

/// Use case for getting user analytics
class GetUserAnalyticsUseCase {
  /// Creates a use case
  GetUserAnalyticsUseCase(this._repository);

  final IAnalyticsRepository _repository;

  /// Get user analytics
  Future<UserAnalytics> call({
    required String userId,
    required String householdId,
  }) async {
    // Try to get cached analytics first
    final UserAnalytics? cached = await _repository.getCachedAnalytics(
      userId: userId,
      householdId: householdId,
    );

    // If cache exists and is recent (within 1 hour), return it
    if (cached != null) {
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(cached.lastUpdated);
      if (difference.inHours < 1) {
        return cached;
      }
    }

    // Otherwise, calculate fresh analytics
    return _repository.calculateAnalytics(
      userId: userId,
      householdId: householdId,
    );
  }
}
