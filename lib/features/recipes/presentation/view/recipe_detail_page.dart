import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/profile/data/badge_service.dart';
import 'package:smartdolap/features/profile/data/profile_stats_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/hero_image_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipe_chips_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/progress_card_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/ingredients_list_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/steps_list_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/mark_as_made_button_widget.dart';
import 'package:smartdolap/product/services/storage/i_storage_service.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';

/// Recipe detail screen
class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({required this.recipe, super.key});

  final Recipe? recipe;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool _isSaving = false;
  final Set<int> _completedSteps = <int>{};
  final Set<int> _collectedIngredients = <int>{};

  double get _stepProgress {
    if (widget.recipe == null || widget.recipe!.steps.isEmpty) return 0.0;
    return _completedSteps.length / widget.recipe!.steps.length;
  }

  double get _ingredientProgress {
    if (widget.recipe == null || widget.recipe!.ingredients.isEmpty) {
      return 0.0;
    }
    return _collectedIngredients.length / widget.recipe!.ingredients.length;
  }

  Future<void> _shareRecipe() async {
    if (widget.recipe == null) return;
    final Recipe recipe = widget.recipe!;
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(recipe.title);
    buffer.writeln();
    buffer.writeln(tr('ingredients_label'));
    for (final String ingredient in recipe.ingredients) {
      buffer.writeln('• $ingredient');
    }
    buffer.writeln();
    buffer.writeln(tr('steps_label'));
    for (int i = 0; i < recipe.steps.length; i++) {
      buffer.writeln('${i + 1}. ${recipe.steps[i]}');
    }
    await Share.share(buffer.toString(), subject: recipe.title);
  }

  Future<void> _printRecipe() async {
    if (widget.recipe == null) return;
    final Recipe recipe = widget.recipe!;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pw.Document doc = pw.Document();
        doc.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    recipe.title,
                    style: pw.Theme.of(
                      context,
                    ).defaultTextStyle.copyWith(fontSize: 24),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    tr('ingredients_label'),
                    style: pw.Theme.of(
                      context,
                    ).defaultTextStyle.copyWith(fontSize: 18),
                  ),
                  pw.SizedBox(height: 10),
                  ...recipe.ingredients.map(
                    (i) => pw.Text(
                      '• $i',
                      style: pw.Theme.of(context).defaultTextStyle,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    tr('steps_label'),
                    style: pw.Theme.of(
                      context,
                    ).defaultTextStyle.copyWith(fontSize: 18),
                  ),
                  pw.SizedBox(height: 10),
                  ...recipe.steps.asMap().entries.map(
                    (e) => pw.Text(
                      '${e.key + 1}. ${e.value}',
                      style: pw.Theme.of(context).defaultTextStyle,
                    ),
                  ),
                ],
              );
            },
          ),
        );
        return doc.save();
      },
    );
  }

  Future<void> _markAsMade() async {
    if (widget.recipe == null) return;

    final bool? addPhoto = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr('recipe_made_title')),
        content: Text(tr('recipe_made_message')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('recipe_made_skip_photo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('recipe_made_add_photo')),
          ),
        ],
      ),
    );

    if (addPhoto == null) return;

    String? imageUrl;
    if (addPhoto == true) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        // Upload to Firebase Storage
        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('recipe_made_error')),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        setState(() => _isSaving = true);
        try {
          final IStorageService storageService = sl<IStorageService>();
          final File imageFile = File(image.path);
          final List<int> imageBytes = await imageFile.readAsBytes();
          imageUrl = await storageService.uploadRecipePhoto(
            userId: userId,
            recipeId: widget.recipe!.id,
            imageBytes: imageBytes as Uint8List,
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('recipe_made_error')),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }
    }

    setState(() => _isSaving = true);

    try {
      final UserRecipeService userRecipeService = sl<UserRecipeService>();
      final ProfileStatsService statsService = sl<ProfileStatsService>();

      // Convert Recipe to UserRecipe
      await userRecipeService.createManual(
        title: widget.recipe!.title,
        ingredients: widget.recipe!.ingredients,
        steps: widget.recipe!.steps,
        description: widget.recipe!.category ?? '',
        tags: <String>[
          if (widget.recipe!.category != null) widget.recipe!.category!,
          if (widget.recipe!.difficulty != null) widget.recipe!.difficulty!,
        ],
        imagePath: imageUrl, // Now it's a Firebase Storage URL
      );

      // Add XP (base 50 XP, +25 if with photo)
      final int xpGained = imageUrl != null ? 75 : 50;
      await statsService.incrementUserRecipes(withPhoto: imageUrl != null);
      await statsService.addXp(xpGained);

      // Check for badges
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final BadgeService badgeService = BadgeService(
          statsService: statsService,
          badgeRepository: sl<IBadgeRepository>(),
          userId: userId,
        );
        await badgeService.checkAndAwardBadges();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'recipe_made_success',
              namedArgs: <String, String>{'xp': '$xpGained'},
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('recipe_made_error')),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _toggleIngredient(int index) {
    setState(() {
      if (_collectedIngredients.contains(index)) {
        _collectedIngredients.remove(index);
      } else {
        _collectedIngredients.add(index);
      }
    });
  }

  void _toggleStep(int index) {
    setState(() {
      if (_completedSteps.contains(index)) {
        _completedSteps.remove(index);
      } else {
        _completedSteps.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recipe == null) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('recipes_title'))),
        body: const EmptyState(messageKey: 'recipes_empty_message'),
      );
    }
    final Recipe data = widget.recipe!;
    return Scaffold(
      appBar: AppBar(
        title: Text(data.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareRecipe,
            tooltip: tr('share_recipe'),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printRecipe,
            tooltip: tr('print_recipe'),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSizes.padding,
              right: AppSizes.padding,
              top: AppSizes.padding,
              bottom: AppSizes.padding + 80, // Buton için ekstra padding
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HeroImageWidget(imageUrl: data.imageUrl),
                SizedBox(height: AppSizes.verticalSpacingM),
                RecipeChipsWidget(recipe: data),
                SizedBox(height: AppSizes.verticalSpacingL),
                ProgressCardWidget(
                  ingredientProgress: _ingredientProgress,
                  stepProgress: _stepProgress,
                  collectedIngredientsCount: _collectedIngredients.length,
                  totalIngredientsCount: data.ingredients.length,
                  completedStepsCount: _completedSteps.length,
                  totalStepsCount: data.steps.length,
                ),
                SizedBox(height: AppSizes.verticalSpacingL),
                IngredientsListWidget(
                  ingredients: data.ingredients,
                  collectedIngredients: _collectedIngredients,
                  onIngredientToggled: _toggleIngredient,
                ),
                SizedBox(height: AppSizes.verticalSpacingL),
                StepsListWidget(
                  steps: data.steps,
                  completedSteps: _completedSteps,
                  onStepToggled: _toggleStep,
                ),
                SizedBox(height: AppSizes.verticalSpacingL),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MarkAsMadeButtonWidget(
              isSaving: _isSaving,
              onPressed: _markAsMade,
            ),
          ),
        ],
      ),
    );
  }
}
