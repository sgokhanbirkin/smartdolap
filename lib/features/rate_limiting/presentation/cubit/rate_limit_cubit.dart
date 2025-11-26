// ignore_for_file: public_member_api_docs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/rate_limiting/domain/entities/api_usage.dart';
import 'package:smartdolap/features/rate_limiting/domain/services/i_rate_limit_service.dart';
import 'package:smartdolap/features/rate_limiting/presentation/cubit/rate_limit_state.dart';

/// Cubit for managing rate limit state
class RateLimitCubit extends Cubit<RateLimitState> {
  RateLimitCubit(this._rateLimitService) : super(const RateLimitState.initial());

  final IRateLimitService _rateLimitService;

  /// Load current usage for a user
  Future<void> loadUsage(String userId) async {
    try {
      emit(const RateLimitState.loading());
      final ApiUsage? usage = await _rateLimitService.getUsage(userId);
      if (usage != null) {
        emit(RateLimitState.loaded(usage));
      } else {
        emit(const RateLimitState.error('Failed to load usage'));
      }
    } on Object catch (error, stackTrace) {
      Logger.error(
        '[RateLimitCubit] Error loading usage',
        error,
        stackTrace,
      );
      emit(RateLimitState.error(error.toString()));
    }
  }

  /// Refresh usage (reload from server)
  Future<void> refresh(String userId) async {
    await loadUsage(userId);
  }
}


