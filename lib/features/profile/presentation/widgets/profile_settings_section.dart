import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/presentation/widgets/preference_controls_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/prompt_preview_card_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Profile settings section widget
/// Displays preferences and settings controls
/// Follows Single Responsibility Principle - only handles settings UI
class ProfileSettingsSection extends StatelessWidget {
  /// Profile settings section constructor
  const ProfileSettingsSection({
    required this.preferences,
    required this.onPrefsChanged,
    super.key,
  });

  /// User preferences
  final PromptPreferences preferences;

  /// Callback when preferences change
  final ValueChanged<PromptPreferences> onPrefsChanged;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PromptPreviewCardWidget(prefs: preferences)
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: 200.ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.08,
              end: 0,
              duration: 400.ms,
              delay: 200.ms,
              curve: Curves.easeOutCubic,
            ),
        SizedBox(height: AppSizes.verticalSpacingXL),
        PreferenceControlsWidget(
          prefs: preferences,
          onPrefsChanged: onPrefsChanged,
        )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: 400.ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.08,
              end: 0,
              duration: 400.ms,
              delay: 400.ms,
              curve: Curves.easeOutCubic,
            ),
        SizedBox(height: AppSizes.verticalSpacingXL),
        // Analytics section
        ListTile(
          leading: Icon(
            Icons.analytics_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(tr('analytics.title')),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(AppRouter.analytics);
          },
        ),
      ],
    );
}

