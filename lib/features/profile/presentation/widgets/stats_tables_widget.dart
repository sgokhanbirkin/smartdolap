import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';

/// Stats tables widget
class StatsTablesWidget extends StatelessWidget {
  const StatsTablesWidget({required this.prefs, super.key});

  final PromptPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, String>> rows = prefs.summaryRows(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.cardPadding * 1.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              tr('profile_summary_title'),
              style: TextStyle(
                fontSize: AppSizes.textL,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
            ...rows.map((MapEntry<String, String> entry) {
              final String label = tr('profile_${entry.key}');
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.verticalSpacingS + 2,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: AppSizes.textS,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: AppSizes.textS,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

