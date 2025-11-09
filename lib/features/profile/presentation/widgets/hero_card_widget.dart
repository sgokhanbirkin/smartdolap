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
    super.key,
  });

  final PromptPreferences prefs;
  final ProfileStats stats;
  final int favoritesCount;
  final AnimationController pulseController;
  final VoidCallback onEditNickname;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (BuildContext context, AuthState state) {
      final domain.User? user =
          state.whenOrNull<domain.User>(authenticated: (domain.User u) => u);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFE0F7FA), Color(0xFFFCE4EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: AppSizes.spacingL * 1.5,
              offset: Offset(0, AppSizes.spacingS),
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
                    fontSize: AppSizes.text,
                    fontWeight: FontWeight.bold,
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
              Text(user.email, style: TextStyle(fontSize: AppSizes.textS)),
            SizedBox(height: AppSizes.verticalSpacingS),
            Text(
              tr('profile_prompt_desc'),
              style: TextStyle(fontSize: AppSizes.textS),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: AppSizes.textXS),
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
      horizontal: AppSizes.spacingL,
      vertical: AppSizes.verticalSpacingS,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(AppSizes.radius),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: AppSizes.spacingXS),
        Text(label, style: TextStyle(fontSize: AppSizes.textS)),
      ],
    ),
  );
}

