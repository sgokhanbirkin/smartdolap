// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/rate_limiting/domain/entities/api_usage.dart';

part 'rate_limit_state.freezed.dart';

@freezed
class RateLimitState with _$RateLimitState {
  const factory RateLimitState.initial() = RateLimitInitial;
  const factory RateLimitState.loading() = RateLimitLoading;
  const factory RateLimitState.loaded(ApiUsage usage) = RateLimitLoaded;
  const factory RateLimitState.error(String message) = RateLimitError;
}


