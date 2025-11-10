import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';

/// Prompt preview card widget
class PromptPreviewCardWidget extends StatelessWidget {
  const PromptPreviewCardWidget({
    required this.prefs,
    super.key,
  });

  final PromptPreferences prefs;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
    ),
    child: Padding(
      padding: EdgeInsets.all(AppSizes.cardPadding * 1.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                tr('profile_prompt_preview'),
                style: TextStyle(
                  fontSize: AppSizes.textL,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: tr('profile_copy_prompt'),
                onPressed: () {
                  // Haptic feedback
                  HapticFeedback.lightImpact();
                  Clipboard.setData(
                    ClipboardData(text: prefs.composePrompt()),
                  );
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
                              tr('profile_prompt_copied'),
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
                },
                icon: const Icon(Icons.copy_all),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Text(
            prefs.composePrompt(),
            style: TextStyle(
              fontSize: AppSizes.textS,
              height: 1.6,
              letterSpacing: 0.1,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Text(
            tr('profile_story_hint'),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ),
  );
}

