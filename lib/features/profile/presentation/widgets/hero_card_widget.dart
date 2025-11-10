import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';

/// Hero card widget for profile page
class HeroCardWidget extends StatelessWidget {
  const HeroCardWidget({
    required this.prefs,
    required this.stats,
    required this.favoritesCount,
    required this.pulseController,
    required this.onEditNickname,
    this.onSettingsTap,
    super.key,
  });

  final PromptPreferences prefs;
  final ProfileStats stats;
  final int favoritesCount;
  final AnimationController pulseController;
  final VoidCallback onEditNickname;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (BuildContext context, AuthState state) {
      final domain.User? user =
          state.whenOrNull<domain.User>(authenticated: (domain.User u) => u);
      return Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            padding: EdgeInsets.all(AppSizes.padding * 1.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const <double>[0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                ScaleTransition(
                  scale: pulseController,
                  child: CircleAvatar(
                    radius: AppSizes.iconXXL,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.person, size: AppSizes.iconXL),
                  ),
                ),
                SizedBox(height: AppSizes.verticalSpacingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      prefs.nickname.isNotEmpty
                          ? prefs.nickname
                          : (user?.displayName ??
                              tr('profile_nickname_placeholder')),
                      style: TextStyle(
                        fontSize: AppSizes.textL,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: AppSizes.iconXS),
                      tooltip: tr('profile_edit_nickname'),
                      onPressed: onEditNickname,
                    ),
                  ],
                ),
                if (user != null)
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: AppSizes.textS,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                SizedBox(height: AppSizes.verticalSpacingS),
                Text(
                  tr('profile_prompt_desc'),
                  style: TextStyle(
                    fontSize: AppSizes.textS,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.verticalSpacingM),
                LevelProgressWidget(stats: stats),
                SizedBox(height: AppSizes.verticalSpacingM),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSizes.spacingM,
                  runSpacing: AppSizes.verticalSpacingS,
                  children: <Widget>[
                    HeroStatBadgeWidget(
                      icon: Icons.auto_awesome,
                      label: tr('profile_generated'),
                      value: '${stats.aiRecipes}',
                    ),
                    HeroStatBadgeWidget(
                      icon: Icons.restaurant,
                      label: tr('profile_user_recipes'),
                      value: '${stats.userRecipes}',
                    ),
                    HeroStatBadgeWidget(
                      icon: Icons.star_border,
                      label: tr('profile_favorites'),
                      value: '$favoritesCount',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Settings icon positioned at top right
          if (onSettingsTap != null)
            Positioned(
              top: AppSizes.spacingS,
              right: AppSizes.spacingS,
              child: IconButton(
                icon: Icon(
                  Icons.settings,
                  size: AppSizes.icon,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: tr('settings'),
                onPressed: onSettingsTap,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// Level progress widget
class LevelProgressWidget extends StatelessWidget {
  const LevelProgressWidget({required this.stats, super.key});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final double progress = stats.nextLevelXp == 0
        ? 0
        : stats.xp / stats.nextLevelXp;
    return Column(
      children: <Widget>[
        Text(
          tr(
            'profile_level',
            namedArgs: <String, String>{'level': '${stats.level}'},
          ),
          style: TextStyle(
            fontSize: AppSizes.textM,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
            height: 1.3,
          ),
        ),
        SizedBox(height: AppSizes.verticalSpacingS),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: AppSizes.spacingXS * 2.5,
          ),
        ),
        SizedBox(height: AppSizes.verticalSpacingS / 2),
        Text(
          tr(
            'profile_level_progress',
            namedArgs: <String, String>{
              'current': '${stats.xp}',
              'next': '${stats.nextLevelXp}',
            },
          ),
          style: TextStyle(
            fontSize: AppSizes.textXS,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Hero stat badge widget
class HeroStatBadgeWidget extends StatelessWidget {
  const HeroStatBadgeWidget({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.spacingM + 2,
      vertical: AppSizes.verticalSpacingS + 2,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(AppSizes.radius),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: AppSizes.iconS,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: AppSizes.spacingS),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.textM,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(width: AppSizes.spacingXS),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

