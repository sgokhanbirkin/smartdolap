import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/profile/data/badge_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart' as domain;
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_profile_stats_service.dart';
import 'package:smartdolap/features/profile/presentation/view/user_recipe_form_page.dart';

/// Profile actions mixin
/// Handles profile-related actions (edit nickname, recipe actions, badge actions)
/// Follows Single Responsibility Principle - only handles action logic
mixin ProfileActionsMixin<T extends StatefulWidget> on State<T> {
  /// Edit nickname
  Future<void> editNickname({
    required PromptPreferences currentPrefs,
    required IProfileStatsService statsService,
    required Future<void> Function(PromptPreferences) onPrefsSaved,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: currentPrefs.nickname,
    );
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(tr('profile_edit_nickname')),
        content: TextField(
          controller: controller,
          style: TextStyle(fontSize: AppSizes.textM),
          decoration: InputDecoration(hintText: tr('profile_nickname_hint')),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('confirm')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final PromptPreferences updatedPrefs = currentPrefs.copyWith(
        nickname: controller.text.trim(),
      );
      await onPrefsSaved(updatedPrefs);
    }
  }

  /// Simulate AI recipe
  Future<void> simulateAiRecipe({
    required IProfileStatsService statsService,
    required ValueChanged<ProfileStats> onStatsUpdated,
    required ValueChanged<List<domain.Badge>> onBadgesUpdated,
  }) async {
    final ProfileStats stats = await statsService.incrementAiRecipes();
    await statsService.addXp(40);
    if (!mounted) {
      return;
    }
    onStatsUpdated(stats);

    // Check for badges
    final AuthState authState = context.read<AuthCubit>().state;
    await authState.whenOrNull(
      authenticated: (domain.User user) async {
        final BadgeService badgeService = BadgeService(
          statsService: statsService,
          badgeRepository: sl<IBadgeRepository>(),
          userId: user.id,
        );
        final List<domain.Badge> newlyUnlocked =
            await badgeService.checkAndAwardBadges();
        if (newlyUnlocked.isNotEmpty && mounted) {
          final List<domain.Badge> updatedBadges =
              await badgeService.getAllBadgesWithStatus();
          onBadgesUpdated(updatedBadges);
        }
      },
    );

    if (!mounted) {
      return;
    }
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: AppSizes.iconS,
            ),
            SizedBox(width: AppSizes.spacingS),
            Expanded(
              child: Text(
                tr('profile_ai_recipe_recorded'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: AppSizes.padding,
          right: AppSizes.padding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Create manual recipe
  Future<void> createManualRecipe({
    required UserRecipeService userRecipeService,
    required IProfileStatsService statsService,
    required ValueChanged<ProfileStats> onStatsUpdated,
    required ValueChanged<List<UserRecipe>> onRecipesUpdated,
    required ValueChanged<List<domain.Badge>> onBadgesUpdated,
  }) async {
    final bool? created = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => UserRecipeFormPage(
          onSubmit: ({
            required String title,
            required List<String> ingredients,
            required List<String> steps,
            String description = '',
            List<String>? tags,
            String? imagePath,
            String? videoPath,
          }) async {
            await userRecipeService.createManual(
              title: title,
              description: description,
              ingredients: ingredients,
              steps: steps,
              tags: tags ?? <String>[],
              imagePath: imagePath,
              videoPath: videoPath,
            );
          },
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    if (created == true) {
      final ProfileStats stats = await statsService.incrementUserRecipes();
      if (!mounted) {
        return;
      }
      onStatsUpdated(stats);
      onRecipesUpdated(userRecipeService.fetch());

      // Check for badges
      final AuthState authState = context.read<AuthCubit>().state;
      await authState.whenOrNull(
        authenticated: (domain.User user) async {
          final BadgeService badgeService = BadgeService(
            statsService: statsService,
            badgeRepository: sl<IBadgeRepository>(),
            userId: user.id,
          );
          final List<domain.Badge> newlyUnlocked =
              await badgeService.checkAndAwardBadges();
          if (newlyUnlocked.isNotEmpty && mounted) {
            final List<domain.Badge> updatedBadges =
                await badgeService.getAllBadgesWithStatus();
            onBadgesUpdated(updatedBadges);
          }
        },
      );
    }
  }

  /// Upload dish photo
  Future<void> uploadDishPhoto({
    required IProfileStatsService statsService,
    required ValueChanged<ProfileStats> onStatsUpdated,
    required ValueChanged<List<domain.Badge>> onBadgesUpdated,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      final ProfileStats stats = await statsService.incrementUserRecipes(
        withPhoto: true,
      );
      if (!mounted) {
        return;
      }
      onStatsUpdated(stats);

      // Check for badges
      final AuthState authState = context.read<AuthCubit>().state;
      await authState.whenOrNull(
        authenticated: (domain.User user) async {
          final BadgeService badgeService = BadgeService(
            statsService: statsService,
            badgeRepository: sl<IBadgeRepository>(),
            userId: user.id,
          );
          final List<domain.Badge> newlyUnlocked =
              await badgeService.checkAndAwardBadges();
          if (newlyUnlocked.isNotEmpty && mounted) {
            final List<domain.Badge> updatedBadges =
                await badgeService.getAllBadgesWithStatus();
            onBadgesUpdated(updatedBadges);
          }
        },
      );

      if (!mounted) {
        return;
      }
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: AppSizes.iconS,
              ),
              SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Text(
                  tr('profile_photo_upload_placeholder'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: AppSizes.padding,
            right: AppSizes.padding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

