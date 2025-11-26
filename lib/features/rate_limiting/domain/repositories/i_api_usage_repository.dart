// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/rate_limiting/domain/entities/api_usage.dart';
import 'package:smartdolap/features/rate_limiting/domain/entities/package_type.dart';

/// Repository interface for API usage data operations
/// Follows Dependency Inversion Principle (DIP) - depends on abstractions
/// Follows Interface Segregation Principle (ISP) - focused interface
abstract class IApiUsageRepository {
  /// Check if user can make a request based on current usage
  /// Returns true if request is allowed, false if rate limit exceeded
  Future<bool> canMakeRequest(String userId);

  /// Increment request count for a user
  /// Should be called after successful API call
  Future<void> incrementRequest(String userId);

  /// Get current API usage for a user
  /// Returns null if user has no usage record
  Future<ApiUsage?> getUsage(String userId);

  /// Update user's package type
  /// This will reset limits based on new package
  Future<void> updatePackage(String userId, PackageType packageType);

  /// Reset daily counters for a user
  /// Typically called at start of new day
  Future<void> resetDailyCounters(String userId);

  /// Reset hourly counters for a user
  /// Typically called at start of new hour
  Future<void> resetHourlyCounters(String userId);
}

