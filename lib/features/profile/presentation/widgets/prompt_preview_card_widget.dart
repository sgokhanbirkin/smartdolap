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
    child: Padding(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                tr('profile_prompt_preview'),
                style: TextStyle(
                  fontSize: AppSizes.textM,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: tr('profile_copy_prompt'),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: prefs.composePrompt()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('profile_prompt_copied'))),
                  );
                },
                icon: const Icon(Icons.copy_all),
              ),
            ],
          ),
          SizedBox(height: AppSizes.verticalSpacingS),
          Text(
            prefs.composePrompt(),
            style: TextStyle(fontSize: AppSizes.textS),
          ),
          SizedBox(height: AppSizes.verticalSpacingS),
          Text(
            tr('profile_story_hint'),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

