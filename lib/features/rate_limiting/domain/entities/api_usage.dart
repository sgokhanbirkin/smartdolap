// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/rate_limiting/domain/entities/package_type.dart';

/// API usage entity representing user's API request usage
/// Immutable class following Clean Architecture principles
class ApiUsage {
  const ApiUsage({
    required this.userId,
    required this.packageType,
    this.dailyRequestCount = 0,
    this.hourlyRequestCount = 0,
    this.lastRequestTime,
    this.resetDate,
  });

  /// Create from JSON map
  factory ApiUsage.fromJson(Map<String, dynamic> json) => ApiUsage(
      userId: json['userId'] as String,
      packageType: PackageType.values.firstWhere(
        (PackageType e) => e.name == json['packageType'],
        orElse: () => PackageType.free,
      ),
      dailyRequestCount: json['dailyRequestCount'] as int? ?? 0,
      hourlyRequestCount: json['hourlyRequestCount'] as int? ?? 0,
      lastRequestTime: json['lastRequestTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['lastRequestTime'] as int,
            )
          : null,
      resetDate: json['resetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['resetDate'] as int,
            )
          : null,
    );

  /// User ID
  final String userId;

  /// Current package type
  final PackageType packageType;

  /// Number of requests made today
  final int dailyRequestCount;

  /// Number of requests made in current hour
  final int hourlyRequestCount;

  /// Timestamp of last request
  final DateTime? lastRequestTime;

  /// Date when counters will reset
  final DateTime? resetDate;

  /// Check if user can make a request based on current limits
  bool canMakeRequest() {
    if (packageType.isUnlimited) {
      return true;
    }

    final DateTime now = DateTime.now();
    
    // Check daily limit
    if (resetDate != null && now.isAfter(resetDate!)) {
      // Reset date passed, allow request
      return true;
    }
    
    if (dailyRequestCount >= packageType.dailyLimit) {
      return false;
    }

    // Check hourly limit
    if (lastRequestTime != null) {
      final Duration hourDifference = now.difference(lastRequestTime!);
      if (hourDifference.inHours < 1) {
        // Still in same hour, check hourly limit
        if (hourlyRequestCount >= packageType.hourlyLimit) {
          return false;
        }
      }
    }

    return true;
  }

  /// Get remaining requests for today
  int get remainingDailyRequests {
    if (packageType.isUnlimited) {
      return -1; // Unlimited
    }
    return (packageType.dailyLimit - dailyRequestCount).clamp(0, packageType.dailyLimit);
  }

  /// Get remaining requests for current hour
  int get remainingHourlyRequests {
    if (packageType.isUnlimited) {
      return -1; // Unlimited
    }
    
    if (lastRequestTime == null) {
      return packageType.hourlyLimit;
    }

    final DateTime now = DateTime.now();
    final Duration hourDifference = now.difference(lastRequestTime!);
    
    if (hourDifference.inHours >= 1) {
      // New hour, reset hourly count
      return packageType.hourlyLimit;
    }
    
    return (packageType.hourlyLimit - hourlyRequestCount).clamp(0, packageType.hourlyLimit);
  }

  /// Create a copy with updated values
  ApiUsage copyWith({
    String? userId,
    PackageType? packageType,
    int? dailyRequestCount,
    int? hourlyRequestCount,
    DateTime? lastRequestTime,
    DateTime? resetDate,
  }) =>
      ApiUsage(
        userId: userId ?? this.userId,
        packageType: packageType ?? this.packageType,
        dailyRequestCount: dailyRequestCount ?? this.dailyRequestCount,
        hourlyRequestCount: hourlyRequestCount ?? this.hourlyRequestCount,
        lastRequestTime: lastRequestTime ?? this.lastRequestTime,
        resetDate: resetDate ?? this.resetDate,
      );

  /// Convert to JSON map
  Map<String, dynamic> toJson() => <String, dynamic>{
      'userId': userId,
      'packageType': packageType.name,
      'dailyRequestCount': dailyRequestCount,
      'hourlyRequestCount': hourlyRequestCount,
      'lastRequestTime': lastRequestTime?.millisecondsSinceEpoch,
      'resetDate': resetDate?.millisecondsSinceEpoch,
    };
}

