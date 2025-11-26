import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_state.dart';

/// Profile cubit - emits immutable profile states
/// In MVVM, this cubit is state-only and all business logic is orchestrated
/// by `ProfileViewModel`.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState.initial());

  /// Emits loading state
  void setLoading() => emit(const ProfileState.loading());

  /// Emits loaded state with provided data
  void setLoaded({
    required PromptPreferences preferences,
    required ProfileStats stats,
    required List<Badge> badges,
    required List<UserRecipe> userRecipes,
    required int favoritesCount,
  }) =>
      emit(
        ProfileState.loaded(
          preferences: preferences,
          stats: stats,
          badges: badges,
          userRecipes: userRecipes,
          favoritesCount: favoritesCount,
        ),
      );

  /// Emits error state with localization key
  void setError(String messageKey) => emit(ProfileState.error(messageKey));

  /// Updates parts of the loaded state without rebuilding from scratch
  void update({
    PromptPreferences? preferences,
    ProfileStats? stats,
    List<Badge>? badges,
    List<UserRecipe>? userRecipes,
    int? favoritesCount,
  }) {
    state.maybeWhen(
      loaded: (
        PromptPreferences currentPrefs,
        ProfileStats currentStats,
        List<Badge> currentBadges,
        List<UserRecipe> currentRecipes,
        int currentFavorites,
      ) {
        emit(
          ProfileState.loaded(
            preferences: preferences ?? currentPrefs,
            stats: stats ?? currentStats,
            badges: badges ?? currentBadges,
            userRecipes: userRecipes ?? currentRecipes,
            favoritesCount: favoritesCount ?? currentFavorites,
          ),
        );
      },
      orElse: () {},
    );
  }
}

