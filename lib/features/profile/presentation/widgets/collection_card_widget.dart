import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';

/// Collection card widget
class CollectionCardWidget extends StatelessWidget {
  const CollectionCardWidget({
    required this.stats,
    required this.userRecipes,
    required this.onSimulateAiRecipe,
    required this.onCreateManualRecipe,
    required this.onUploadDishPhoto,
    super.key,
  });

  final ProfileStats stats;
  final List<UserRecipe> userRecipes;
  final VoidCallback onSimulateAiRecipe;
  final VoidCallback onCreateManualRecipe;
  final VoidCallback onUploadDishPhoto;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            tr('profile_collection_title'),
            style: TextStyle(
              fontSize: AppSizes.textM,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Wrap(
            spacing: AppSizes.spacingM,
            runSpacing: AppSizes.verticalSpacingS,
            alignment: WrapAlignment.center,
            children: <Widget>[
              UsageChipWidget(
                label: tr('profile_generated'),
                value: '${stats.aiRecipes}',
                icon: Icons.auto_awesome,
              ),
              UsageChipWidget(
                label: tr('profile_user_recipes'),
                value: '${stats.userRecipes}',
                icon: Icons.restaurant,
              ),
              UsageChipWidget(
                label: tr('profile_photo_uploads'),
                value: '${stats.photoUploads}',
                icon: Icons.photo_camera_outlined,
              ),
            ],
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          CollectionActionsWidget(
            onSimulateAiRecipe: onSimulateAiRecipe,
            onCreateManualRecipe: onCreateManualRecipe,
            onUploadDishPhoto: onUploadDishPhoto,
          ),
          if (userRecipes.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSizes.verticalSpacingM),
            Text(tr('profile_recent_recipes')),
            ...userRecipes
                .take(3)
                .map(
                  (UserRecipe recipe) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      recipe.isAIRecommendation
                          ? Icons.auto_awesome
                          : Icons.restaurant,
                    ),
                    title: Text(recipe.title),
                    subtitle: Text(
                      recipe.description.isEmpty
                          ? tr('profile_recipe_advice')
                          : recipe.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
          ],
        ],
      ),
    ),
  );
}

/// Usage chip widget
class UsageChipWidget extends StatelessWidget {
  const UsageChipWidget({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: AppSizes.spacingXXL * 3.4375,
    padding: EdgeInsets.all(AppSizes.padding),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      color: Theme.of(context).colorScheme.secondaryContainer,
    ),
    child: Column(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        SizedBox(height: AppSizes.verticalSpacingS),
        Text(value, style: TextStyle(fontSize: AppSizes.textL)),
        Text(label, textAlign: TextAlign.center),
      ],
    ),
  );
}

/// Collection actions widget
class CollectionActionsWidget extends StatelessWidget {
  const CollectionActionsWidget({
    required this.onSimulateAiRecipe,
    required this.onCreateManualRecipe,
    required this.onUploadDishPhoto,
    super.key,
  });

  final VoidCallback onSimulateAiRecipe;
  final VoidCallback onCreateManualRecipe;
  final VoidCallback onUploadDishPhoto;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final bool twoColumns = constraints.maxWidth >= 480;
      final double width = twoColumns
          ? (constraints.maxWidth - AppSizes.spacingM) / 2
          : constraints.maxWidth;
      final List<Widget> buttons = <Widget>[
        SizedBox(
          width: width,
          child: FilledButton.icon(
            onPressed: onSimulateAiRecipe,
            icon: const Icon(Icons.bolt),
            label: Text(tr('profile_simulate_ai')),
          ),
        ),
        SizedBox(
          width: width,
          child: OutlinedButton.icon(
            onPressed: onCreateManualRecipe,
            icon: const Icon(Icons.note_add_outlined),
            label: Text(tr('profile_add_manual_recipe')),
          ),
        ),
        SizedBox(
          width: width,
          child: OutlinedButton.icon(
            onPressed: onUploadDishPhoto,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(tr('profile_upload_photo')),
          ),
        ),
      ];
      return Wrap(
        spacing: AppSizes.spacingM,
        runSpacing: AppSizes.spacingM,
        children: buttons,
      );
    },
  );
}

