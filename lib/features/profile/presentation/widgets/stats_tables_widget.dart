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
      child: Padding(
        padding: EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              tr('profile_summary_title'),
              style: TextStyle(
                fontSize: AppSizes.textM,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingS),
            ...rows.map((MapEntry<String, String> entry) {
              final String label = tr('profile_${entry.key}');
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.verticalSpacingS,
                ),
                child: Row(
                  children: <Widget>[
                    Text(label),
                    const Spacer(),
                    Text(
                      entry.value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

