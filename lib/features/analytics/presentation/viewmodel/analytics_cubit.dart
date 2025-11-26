import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';
import 'package:smartdolap/features/analytics/domain/use_cases/get_user_analytics_usecase.dart';
import 'package:smartdolap/features/analytics/presentation/viewmodel/analytics_state.dart';

/// Cubit for managing analytics state
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit({required this.getUserAnalytics})
    : super(const AnalyticsInitial());

  final GetUserAnalyticsUseCase getUserAnalytics;

  Future<void> loadAnalytics({
    required String userId,
    required String householdId,
  }) async {
    emit(const AnalyticsLoading());
    try {
      final UserAnalytics analytics = await getUserAnalytics.call(
        userId: userId,
        householdId: householdId,
      );
      emit(AnalyticsLoaded(analytics));
    } on Object catch (error, stackTrace) {
      Logger.error(
        '[AnalyticsCubit] Error loading analytics',
        error,
        stackTrace,
      );
      emit(AnalyticsFailure(error.toString()));
    }
  }

  Future<void> refresh({
    required String userId,
    required String householdId,
  }) async {
    await loadAnalytics(userId: userId, householdId: householdId);
  }
}
