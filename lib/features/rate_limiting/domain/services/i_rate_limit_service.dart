// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/rate_limiting/domain/entities/api_usage.dart';
import 'package:smartdolap/features/rate_limiting/domain/entities/package_type.dart';

/// Service interface for rate limiting
/// Provides high-level API for checking and tracking API usage
abstract class IRateLimitService {
  /// Check if user can make an API request
  /// Returns true if request is allowed, false otherwise
  Future<bool> canMakeRequest(String userId);

  /// Track an API request (increment counter)
  /// Should be called after successful API call
  Future<void> trackRequest(String userId);

  /// Get current API usage for a user
  Future<ApiUsage?> getUsage(String userId);

  /// Update user's package type
  Future<void> updatePackage(String userId, PackageType packageType);
}


