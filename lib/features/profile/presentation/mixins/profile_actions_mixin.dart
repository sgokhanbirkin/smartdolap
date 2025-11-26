import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/presentation/view/user_recipe_form_page.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_view_model.dart';

/// Profile actions mixin
/// Handles profile-related actions (edit nickname, recipe actions, badge actions)
/// Follows Single Responsibility Principle - only handles action logic
mixin ProfileActionsMixin<T extends StatefulWidget> on State<T> {
  /// Edit nickname
  Future<void> editNickname({
    required PromptPreferences currentPrefs,
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
    required ProfileViewModel viewModel,
  }) async {
    final bool success = await viewModel.recordAiRecipe();
    if (!mounted) {
      return;
    }
    if (success) {
      await HapticFeedback.lightImpact();
      if (!mounted) {
        return;
      }
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
    } else {
      _showErrorSnack();
    }
  }

  /// Create manual recipe
  Future<void> createManualRecipe({
    required ProfileViewModel viewModel,
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
          }) =>
              viewModel.createManualRecipe(
            title: title,
            ingredients: ingredients,
            steps: steps,
            description: description,
            tags: tags,
            imagePath: imagePath,
            videoPath: videoPath,
            ),
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    if (created == true) {
      await HapticFeedback.lightImpact();
      if (!mounted) {
        return;
      }
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
                  tr('profile_manual_recipe_created'),
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

  /// Upload dish photo
  Future<void> uploadDishPhoto({
    required ProfileViewModel viewModel,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      final bool success = await viewModel.recordDishPhotoUpload();
      if (success && mounted) {
        await HapticFeedback.lightImpact();
        if (!mounted) {
          return;
        }
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
      } else {
        _showErrorSnack();
      }
    }
  }

  void _showErrorSnack() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr('error_generic'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
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
