import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/constants/mvp_flags.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart' as domain;
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/presentation/utils/badge_progress_helper.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_grid_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_preview_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/collection_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/hero_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/stats_tables_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Profile display section widget
/// Displays hero card, stats, and badges
/// Follows Single Responsibility Principle - only handles display logic
class ProfileDisplaySection extends StatelessWidget {
  /// Profile display section constructor
  const ProfileDisplaySection({
    required this.preferences,
    required this.stats,
    required this.badges,
    required this.userRecipes,
    required this.favoritesCount,
    required this.pulseController,
    required this.onEditNickname,
    required this.onSettingsTap,
    required this.onSimulateAiRecipe,
    required this.onCreateManualRecipe,
    required this.onUploadDishPhoto,
    super.key,
  });

  /// User preferences
  final PromptPreferences preferences;

  /// Profile statistics
  final ProfileStats stats;

  /// User badges
  final List<domain.Badge> badges;

  /// User recipes
  final List<UserRecipe> userRecipes;

  /// Favorites count
  final int favoritesCount;

  /// Pulse animation controller
  final AnimationController pulseController;

  /// Callback when edit nickname is pressed
  final VoidCallback onEditNickname;

  /// Callback when settings is tapped
  final VoidCallback onSettingsTap;

  /// Callback when simulate AI recipe is pressed
  final VoidCallback onSimulateAiRecipe;

  /// Callback when create manual recipe is pressed
  final VoidCallback onCreateManualRecipe;

  /// Callback when upload dish photo is pressed
  final VoidCallback onUploadDishPhoto;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        HeroCardWidget(
          prefs: preferences,
          stats: stats,
          favoritesCount: favoritesCount,
          pulseController: pulseController,
          onEditNickname: onEditNickname,
          onSettingsTap: onSettingsTap,
        )
            .animate()
            .fadeIn(
              duration: 500.ms,
              delay: 100.ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.1,
              end: 0,
              duration: 500.ms,
              delay: 100.ms,
              curve: Curves.easeOutCubic,
            ),
        SizedBox(height: AppSizes.verticalSpacingXL),
        StatsTablesWidget(prefs: preferences)
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: 300.ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.08,
              end: 0,
              duration: 400.ms,
              delay: 300.ms,
              curve: Curves.easeOutCubic,
            ),
        SizedBox(height: AppSizes.verticalSpacingXL),
        BadgePreviewWidget(
          badges: BadgeProgressHelper.getPreviewBadges(badges, stats),
          onViewAll: () {
            Navigator.of(context).pushNamed(AppRouter.badges);
          },
          onBadgeTap: (domain.Badge badge) {
            showDialog<void>(
              context: context,
              builder: (_) => BadgeDetailDialogWidget(badge: badge),
            );
          },
        )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: 500.ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.08,
              end: 0,
              duration: 400.ms,
              delay: 500.ms,
              curve: Curves.easeOutCubic,
            ),
        // Advanced sections (optional - can be hidden)
        if (kEnableAdvancedProfileSections) ...<Widget>[
          SizedBox(height: AppSizes.verticalSpacingL),
          CollectionCardWidget(
            stats: stats,
            userRecipes: userRecipes,
            onSimulateAiRecipe: onSimulateAiRecipe,
            onCreateManualRecipe: onCreateManualRecipe,
            onUploadDishPhoto: onUploadDishPhoto,
          ),
        ],
      ],
    );
}

