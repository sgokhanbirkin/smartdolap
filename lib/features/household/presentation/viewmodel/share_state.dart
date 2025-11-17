import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/household/domain/entities/household_message.dart';
import 'package:smartdolap/features/household/domain/entities/shared_recipe.dart';

part 'share_state.freezed.dart';

/// Share state - Presentation layer state management
@freezed
class ShareState with _$ShareState {
  /// Initial state
  const factory ShareState.initial() = _Initial;

  /// Loading state
  const factory ShareState.loading() = _Loading;

  /// Loaded state with messages and shared recipes
  const factory ShareState.loaded({
    required List<HouseholdMessage> messages,
    required List<SharedRecipe> sharedRecipes,
  }) = _Loaded;

  /// Error state
  const factory ShareState.error(String message) = _Error;
}

