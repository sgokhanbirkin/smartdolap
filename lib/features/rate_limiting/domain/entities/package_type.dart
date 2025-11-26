// ignore_for_file: public_member_api_docs

/// Package type enum for rate limiting
/// Defines different subscription tiers with their limits
enum PackageType {
  /// Free tier with basic limits
  free,

  /// Premium tier with higher limits
  premium,

  /// Enterprise tier with unlimited access
  enterprise;

  /// Get request limit per day for this package type
  int get dailyLimit {
    switch (this) {
      case PackageType.free:
        return 50;
      case PackageType.premium:
        return 500;
      case PackageType.enterprise:
        return -1; // -1 means unlimited
    }
  }

  /// Get request limit per hour for this package type
  int get hourlyLimit {
    switch (this) {
      case PackageType.free:
        return 10;
      case PackageType.premium:
        return 100;
      case PackageType.enterprise:
        return -1; // -1 means unlimited
    }
  }

  /// Check if package has unlimited access
  bool get isUnlimited => dailyLimit == -1;
}

