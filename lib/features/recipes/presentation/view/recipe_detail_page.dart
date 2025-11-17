import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/analytics/domain/services/i_analytics_service.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_detail_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/hero_image_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/ingredients_list_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/mark_as_made_button_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/progress_card_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipe_chips_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/steps_list_widget.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late final RecipeDetailService _recipeDetailService;
  late final IAnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _recipeDetailService = RecipeDetailService();
    _analyticsService = sl<IAnalyticsService>();
  }

  /// Determine meal type based on current time
  String _getMealType() {
    final int hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) {
      return 'breakfast';
    } else if (hour >= 11 && hour < 15) {
      return 'lunch';
    } else if (hour >= 15 && hour < 21) {
      return 'dinner';
    } else {
      return 'snack';
    }
  }

  double get _stepProgress {
    if (widget.recipe == null || widget.recipe!.steps.isEmpty) {
      return 0.0;
    }
    return _completedSteps.length / widget.recipe!.steps.length;
  }

  double get _ingredientProgress {
    if (widget.recipe == null || widget.recipe!.ingredients.isEmpty) {
      return 0.0;
    }
    return _collectedIngredients.length / widget.recipe!.ingredients.length;
  }

  Future<void> _shareRecipe() async {
    if (widget.recipe == null) {
      return;
    }
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
    if (widget.recipe == null) {
      return;
    }
    final Recipe recipe = widget.recipe!;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pw.Document doc = pw.Document();
        doc.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) => pw.Column(
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
                ...recipe.ingredients.map<pw.Widget>(
                  (String i) => pw.Text(
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
                ...recipe.steps.asMap().entries.map<pw.Widget>(
                  (MapEntry<int, String> e) => pw.Text(
                    '${e.key + 1}. ${e.value}',
                    style: pw.Theme.of(context).defaultTextStyle,
                  ),
                ),
              ],
            ),
          ),
        );
        return doc.save();
      },
    );
  }

  Future<void> _markAsMade() async {
    if (widget.recipe == null) {
      return;
    }

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

    if (addPhoto == null) {
      return;
    }

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
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr('recipe_made_error'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1,
                left: AppSizes.padding,
                right: AppSizes.padding,
              ),
            ),
          );
          return;
        }

        setState(() => _isSaving = true);
        try {
          final File imageFile = File(image.path);
          final List<int> imageBytes = await imageFile.readAsBytes();
          imageUrl = await _recipeDetailService.uploadRecipePhoto(
            userId: userId,
            recipeId: widget.recipe!.id,
            imageBytes: imageBytes as Uint8List,
          );
        } on Exception {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr('recipe_made_error'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1,
                left: AppSizes.padding,
                right: AppSizes.padding,
              ),
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }
    }

    setState(() => _isSaving = true);

    final RecipeMadeResult result = await _recipeDetailService.markRecipeAsMade(
      recipe: widget.recipe!,
      imageUrl: imageUrl,
    );

    if (!mounted) {
      return;
    }

    if (result.success) {
      // Record meal consumption for analytics
      final AuthState authState = context.read<AuthCubit>().state;
      await authState.maybeWhen(
        authenticated: (domain.User user) async {
          if (user.householdId != null) {
            try {
              await _analyticsService.recordRecipeConsumption(
                userId: user.id,
                householdId: user.householdId!,
                recipeId: widget.recipe!.id,
                recipeTitle: widget.recipe!.title,
                ingredients: widget.recipe!.ingredients,
                meal: _getMealType(),
              );
            } on Exception catch (e) {
              // Silently fail - analytics is not critical
              debugPrint('[RecipeDetailPage] Error recording consumption: $e');
            }
          }
        },
        orElse: () async {},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('recipes.marked_as_made'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: AppSizes.padding,
            right: AppSizes.padding,
          ),
        ),
      );
      Navigator.of(context).pop(true); // true döndür - yaptıklarım güncellensin
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('common.unexpected_error'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: AppSizes.padding,
            right: AppSizes.padding,
          ),
        ),
      );
    }

    setState(() => _isSaving = false);
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
