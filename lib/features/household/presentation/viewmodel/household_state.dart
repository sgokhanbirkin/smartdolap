import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/household/domain/entities/household.dart';

part 'household_state.freezed.dart';

/// Household state - Presentation layer state management
@freezed
class HouseholdState with _$HouseholdState {
  /// Initial state
  const factory HouseholdState.initial() = _Initial;

  /// Loading state
  const factory HouseholdState.loading() = _Loading;

  /// Household loaded state
  const factory HouseholdState.loaded(Household household) = _Loaded;

  /// No household state (user not in a household)
  const factory HouseholdState.noHousehold() = _NoHousehold;

  /// Error state
  const factory HouseholdState.error(String message) = _Error;
}

