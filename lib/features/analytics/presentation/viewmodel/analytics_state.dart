// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';

/// Analytics state base class
abstract class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  const AnalyticsLoaded(this.analytics);
  final UserAnalytics analytics;
}

class AnalyticsFailure extends AnalyticsState {
  const AnalyticsFailure(this.message);
  final String message;
}

