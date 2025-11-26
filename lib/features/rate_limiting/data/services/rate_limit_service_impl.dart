// ignore_for_file: public_member_api_docs

import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/rate_limiting/domain/entities/api_usage.dart';
import 'package:smartdolap/features/rate_limiting/domain/entities/package_type.dart';
import 'package:smartdolap/features/rate_limiting/domain/repositories/i_api_usage_repository.dart';
import 'package:smartdolap/features/rate_limiting/domain/services/i_rate_limit_service.dart';

/// Implementation of rate limit service
class RateLimitServiceImpl implements IRateLimitService {
  RateLimitServiceImpl(this._repository);

  final IApiUsageRepository _repository;

  @override
  Future<bool> canMakeRequest(String userId) async {
    try {
      return await _repository.canMakeRequest(userId);
    } catch (e) {
      Logger.error('[RateLimitService] Error checking can make request', e);
      // Allow request on error to avoid blocking users
      return true;
    }
  }

  @override
  Future<void> trackRequest(String userId) async {
    try {
      await _repository.incrementRequest(userId);
    } catch (e) {
      Logger.error('[RateLimitService] Error tracking request', e);
      // Don't rethrow - tracking failure shouldn't block the app
    }
  }

  @override
  Future<ApiUsage?> getUsage(String userId) async {
    try {
      return await _repository.getUsage(userId);
    } catch (e) {
      Logger.error('[RateLimitService] Error getting usage', e);
      return null;
    }
  }

  @override
  Future<void> updatePackage(String userId, PackageType packageType) async {
    try {
      await _repository.updatePackage(userId, packageType);
    } catch (e) {
      Logger.error('[RateLimitService] Error updating package', e);
      rethrow;
    }
  }
}


