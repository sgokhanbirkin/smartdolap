import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/gamification/services/badge_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_profile_stats_service.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_prompt_preference_service.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_cubit.dart';

/// ViewModel that orchestrates profile feature business logic.
class ProfileViewModel {
  ProfileViewModel({
    required ProfileCubit cubit,
    required IPromptPreferenceService prefService,
    required IProfileStatsService statsService,
    required UserRecipeService userRecipeService,
    required AuthCubit authCubit,
    required IBadgeRepository badgeRepository,
    HiveInterface? hive,
  }) : _cubit = cubit,
       _prefService = prefService,
       _statsService = statsService,
       _userRecipeService = userRecipeService,
       _authCubit = authCubit,
       _badgeRepository = badgeRepository,
       _hive = hive ?? Hive;

  final ProfileCubit _cubit;
  final IPromptPreferenceService _prefService;
  final IProfileStatsService _statsService;
  final UserRecipeService _userRecipeService;
  final AuthCubit _authCubit;
  final IBadgeRepository _badgeRepository;
  final HiveInterface _hive;

  StreamSubscription<ProfileStats>? _statsSubscription;

  /// Initializes profile data and starts listening for stats changes.
  Future<void> initialize() async {
    _cubit.setLoading();
    try {
      final PromptPreferences prefs = _prefService.getPreferences();
      final ProfileStats stats = _statsService.load();
      // Set current user ID for data isolation
      _authCubit.state.whenOrNull(
        authenticated: (domain.User user) {
          _userRecipeService.setCurrentUserId(user.id);
        },
      );
      final List<UserRecipe> userRecipes = _userRecipeService.fetch();
      final int favoritesCount = await _loadFavoritesCount();
      final List<Badge> badges = await _loadBadges();

      _subscribeToStatsUpdates();

      _cubit.setLoaded(
        preferences: prefs,
        stats: stats,
        badges: badges,
        userRecipes: userRecipes,
        favoritesCount: favoritesCount,
      );
    } on Exception catch (error, stackTrace) {
      debugPrint('[ProfileViewModel] initialize error: $error');
      debugPrint(stackTrace.toString());
      _cubit.setError('profile_error_generic');
    }
  }

  /// Persists prompt preferences and updates UI state.
  Future<void> savePreferences(PromptPreferences prefs) async {
    try {
      await _prefService.savePreferences(prefs);
      _cubit.update(preferences: prefs);
    } on Exception catch (error, stackTrace) {
      debugPrint('[ProfileViewModel] savePreferences error: $error');
      debugPrint(stackTrace.toString());
      _cubit.setError('profile_preferences_error');
    }
  }

  /// Reloads profile data from scratch.
  Future<void> refresh() => initialize();

  /// Records an AI recipe simulation and updates stats/badges.
  Future<bool> recordAiRecipe() async {
    try {
      final ProfileStats stats = await _statsService.incrementAiRecipes();
      await _statsService.addXp(40);
      _cubit.update(stats: stats);
      await _refreshBadges();
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('[ProfileViewModel] recordAiRecipe error: $error');
      debugPrint(stackTrace.toString());
      return false;
    }
  }

  /// Creates a manual recipe entry sourced from the user form.
  Future<bool> createManualRecipe({
    required String title,
    required List<String> ingredients,
    required List<String> steps,
    String description = '',
    List<String>? tags,
    String? imagePath,
    String? videoPath,
  }) async {
    try {
      // Set current user ID for data isolation
      _authCubit.state.whenOrNull(
        authenticated: (domain.User user) {
          _userRecipeService.setCurrentUserId(user.id);
        },
      );
      await _userRecipeService.createManual(
        title: title,
        description: description,
        ingredients: ingredients,
        steps: steps,
        tags: tags ?? <String>[],
        imagePath: imagePath,
        videoPath: videoPath,
      );
      final ProfileStats stats = await _statsService.incrementUserRecipes();
      final List<UserRecipe> recipes = _userRecipeService.fetch();
      _cubit
        ..update(stats: stats)
        ..update(userRecipes: recipes);
      await _refreshBadges();
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('[ProfileViewModel] createManualRecipe error: $error');
      debugPrint(stackTrace.toString());
      return false;
    }
  }

  /// Records a dish photo upload action.
  Future<bool> recordDishPhotoUpload() async {
    try {
      final ProfileStats stats = await _statsService.incrementUserRecipes(
        withPhoto: true,
      );
      _cubit.update(stats: stats);
      await _refreshBadges();
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('[ProfileViewModel] recordDishPhotoUpload error: $error');
      debugPrint(stackTrace.toString());
      return false;
    }
  }

  /// Frees resources.
  Future<void> dispose() async {
    await _statsSubscription?.cancel();
    _statsSubscription = null;
  }

  void _subscribeToStatsUpdates() {
    _statsSubscription?.cancel();
    _statsSubscription = _statsService.watch().listen((ProfileStats stats) {
      _cubit.update(stats: stats);
    });
  }

  Future<int> _loadFavoritesCount() async {
    const String favoritesBox = 'favorite_recipes';
    if (_hive.isBoxOpen(favoritesBox)) {
      return _hive.box<dynamic>(favoritesBox).length;
    }
    final Box<dynamic> box = await _hive.openBox<dynamic>(favoritesBox);
    return box.length;
  }

  Future<List<Badge>> _loadBadges() async {
    List<Badge> badges = <Badge>[];
    await _authCubit.state.whenOrNull(
      authenticated: (domain.User user) async {
        try {
          final BadgeService badgeService = BadgeService(
            statsService: _statsService,
            badgeRepository: _badgeRepository,
            userId: user.id,
          );
          badges = await badgeService.getAllBadgesWithStatus();
        } on Exception catch (error, stackTrace) {
          debugPrint('[ProfileViewModel] loadBadges error: $error');
          debugPrint(stackTrace.toString());
        }
      },
    );
    return badges;
  }

  Future<void> _refreshBadges() async {
    final List<Badge> badges = await _loadBadges();
    _cubit.update(badges: badges);
  }
}
