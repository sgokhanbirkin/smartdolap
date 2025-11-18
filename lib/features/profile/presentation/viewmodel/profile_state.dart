import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';

part 'profile_state.freezed.dart';

/// Profile state - represents the state of profile data
@freezed
class ProfileState with _$ProfileState {
  /// Initial state
  const factory ProfileState.initial() = _Initial;

  /// Loading state
  const factory ProfileState.loading() = _Loading;

  /// Loaded state with profile data
  const factory ProfileState.loaded({
    required PromptPreferences preferences,
    required ProfileStats stats,
    required List<Badge> badges,
    required List<UserRecipe> userRecipes,
    required int favoritesCount,
  }) = _Loaded;

  /// Error state
  const factory ProfileState.error(String message) = _Error;
}

