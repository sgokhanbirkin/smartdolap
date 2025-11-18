import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/profile/data/badge_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_profile_stats_service.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_prompt_preference_service.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_state.dart';

/// Profile cubit - Manages profile state and operations
/// Follows Single Responsibility Principle - only handles profile data management
class ProfileCubit extends Cubit<ProfileState> {
  /// Profile cubit constructor
  ProfileCubit({
    required this.prefService,
    required this.statsService,
    required this.userRecipeService,
    required this.authCubit,
  }) : super(const ProfileState.initial()) {
    _initialize();
  }

  /// Prompt preference service
  final IPromptPreferenceService prefService;

  /// Profile stats service
  final IProfileStatsService statsService;

  /// User recipe service
  final UserRecipeService userRecipeService;

  /// Auth cubit for user information
  final AuthCubit authCubit;

  StreamSubscription<ProfileStats>? _statsSubscription;

  /// Initialize and load profile data
  Future<void> _initialize() async {
    emit(const ProfileState.loading());

    try {
      // Load preferences
      final PromptPreferences prefs = prefService.getPreferences();

      // Load stats
      final ProfileStats stats = statsService.load();

      // Load user recipes
      final List<UserRecipe> userRecipes = userRecipeService.fetch();

      // Load favorites count
      final Box<dynamic> favBox = Hive.isBoxOpen('favorite_recipes')
          ? Hive.box<dynamic>('favorite_recipes')
          : await Hive.openBox<dynamic>('favorite_recipes');
      final int favoritesCount = favBox.length;

      // Load badges
      final AuthState authState = authCubit.state;
      List<Badge> badges = <Badge>[];

      await authState.whenOrNull(
        authenticated: (domain.User user) async {
          try {
            final BadgeService badgeService = BadgeService(
              statsService: statsService,
              badgeRepository: sl<IBadgeRepository>(),
              userId: user.id,
            );
            badges = await badgeService.getAllBadgesWithStatus();
          } on Exception catch (e) {
            debugPrint('[ProfileCubit] Badge yükleme hatası: $e');
            badges = <Badge>[];
          }
        },
      );

      // Listen to stats changes
      _statsSubscription = statsService.watch().listen((ProfileStats updatedStats) {
        state.maybeWhen(
          loaded: (
            PromptPreferences prefs,
            ProfileStats _,
            List<Badge> badges,
            List<UserRecipe> userRecipes,
            int favoritesCount,
          ) {
            emit(
              ProfileState.loaded(
                preferences: prefs,
                stats: updatedStats,
                badges: badges,
                userRecipes: userRecipes,
                favoritesCount: favoritesCount,
              ),
            );
          },
          orElse: () {},
        );
      });

      emit(
        ProfileState.loaded(
          preferences: prefs,
          stats: stats,
          badges: badges,
          userRecipes: userRecipes,
          favoritesCount: favoritesCount,
        ),
      );
    } on Exception catch (e, stackTrace) {
      debugPrint('[ProfileCubit] _initialize hatası: $e');
      debugPrint('[ProfileCubit] Stack trace: $stackTrace');
      emit(ProfileState.error(e.toString()));
    }
  }

  /// Save preferences
  Future<void> savePreferences(PromptPreferences prefs) async {
    await prefService.savePreferences(prefs);
    state.maybeWhen(
      loaded: (
        PromptPreferences _,
        ProfileStats stats,
        List<Badge> badges,
        List<UserRecipe> userRecipes,
        int favoritesCount,
      ) {
        emit(
          ProfileState.loaded(
            preferences: prefs,
            stats: stats,
            badges: badges,
            userRecipes: userRecipes,
            favoritesCount: favoritesCount,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Refresh profile data
  Future<void> refresh() async {
    await _initialize();
  }

  /// Update stats after action (e.g., recipe creation)
  Future<void> updateStats(ProfileStats newStats) async {
    state.maybeWhen(
      loaded: (
        PromptPreferences prefs,
        ProfileStats _,
        List<Badge> badges,
        List<UserRecipe> userRecipes,
        int favoritesCount,
      ) {
        emit(
          ProfileState.loaded(
            preferences: prefs,
            stats: newStats,
            badges: badges,
            userRecipes: userRecipes,
            favoritesCount: favoritesCount,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Update badges after action
  Future<void> updateBadges(List<Badge> newBadges) async {
    state.maybeWhen(
      loaded: (
        PromptPreferences prefs,
        ProfileStats stats,
        List<Badge> _,
        List<UserRecipe> userRecipes,
        int favoritesCount,
      ) {
        emit(
          ProfileState.loaded(
            preferences: prefs,
            stats: stats,
            badges: newBadges,
            userRecipes: userRecipes,
            favoritesCount: favoritesCount,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Update user recipes
  Future<void> updateUserRecipes(List<UserRecipe> newRecipes) async {
    state.maybeWhen(
      loaded: (
        PromptPreferences prefs,
        ProfileStats stats,
        List<Badge> badges,
        List<UserRecipe> _,
        int favoritesCount,
      ) {
        emit(
          ProfileState.loaded(
            preferences: prefs,
            stats: stats,
            badges: badges,
            userRecipes: newRecipes,
            favoritesCount: favoritesCount,
          ),
        );
      },
      orElse: () {},
    );
  }

  @override
  Future<void> close() {
    _statsSubscription?.cancel();
    return super.close();
  }
}

