import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_colors.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/recipes/presentation/utils/ingredient_message_generator.dart';

/// Full-screen loading overlay for recipe suggestions
/// Shows animated messages analyzing selected ingredients
class RecipeLoadingOverlayWidget extends StatefulWidget {
  /// Creates a recipe loading overlay
  const RecipeLoadingOverlayWidget({
    required this.selectedIngredients,
    this.note,
    super.key,
  });

  /// List of selected ingredient names
  final List<String> selectedIngredients;

  /// Optional note from user
  final String? note;

  @override
  State<RecipeLoadingOverlayWidget> createState() =>
      _RecipeLoadingOverlayWidgetState();
}

class _RecipeLoadingOverlayWidgetState
    extends State<RecipeLoadingOverlayWidget> {
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  /// Fun messages analyzing ingredients with humor
  List<String> get _messages {
    final List<String> messages = <String>[];
    final List<String> ingredients = widget.selectedIngredients;

    if (ingredients.isEmpty) {
      return <String>[tr('recipes.loading.analyzing_combinations')];
    }

    // Create combination messages (2-3 ingredients at a time)
    for (int i = 0; i < ingredients.length; i += 2) {
      if (i + 1 < ingredients.length) {
        // 2 ingredients combination
        final String ingredient1 = ingredients[i];
        final String ingredient2 = ingredients[i + 1];
        messages.add(_getCombinationMessage(ingredient1, ingredient2));
      } else {
        // Single ingredient (last one)
        messages.add(_getSingleIngredientMessage(ingredients[i]));
      }
    }

    // Add general messages
    messages.addAll(<String>[
      tr('recipes.loading.analyzing_combinations'),
      tr('recipes.loading.checking_recipes'),
      tr('recipes.loading.finalizing'),
    ]);

    return messages;
  }

  String _getCombinationMessage(String ingredient1, String ingredient2) {
    // Use the new message generator with decision tree logic
    return IngredientMessageGenerator.generateCombinationMessage(
      ingredient1,
      ingredient2,
    );
  }

  String _getSingleIngredientMessage(String ingredient) {
    final String lowerIngredient = ingredient.toLowerCase();
    final String baseMessage = tr('recipes.loading.analyzing_ingredient',
        namedArgs: <String, String>{'ingredient': ingredient});

    // Fun messages based on ingredient type
    if (lowerIngredient.contains('patlıcan') ||
        lowerIngredient.contains('biber') ||
        lowerIngredient.contains('domates')) {
      return '$baseMessage ${tr('recipes.loading.fun.vegetable')}';
    } else if (lowerIngredient.contains('tavuk') ||
        lowerIngredient.contains('et') ||
        lowerIngredient.contains('balık')) {
      return '$baseMessage ${tr('recipes.loading.fun.protein')}';
    } else if (lowerIngredient.contains('fasulye') ||
        lowerIngredient.contains('mercimek') ||
        lowerIngredient.contains('nohut')) {
      return '$baseMessage ${tr('recipes.loading.fun.legume')}';
    } else if (lowerIngredient.contains('yumurta')) {
      return '$baseMessage ${tr('recipes.loading.fun.egg')}';
    } else {
      return baseMessage;
    }
  }

  @override
  void initState() {
    super.initState();
    _startMessageRotation();
  }

  void _startMessageRotation() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Fixed popup dimensions: 90% width (5% margin on each side), 50% height
    final double popupWidth = screenWidth * 0.9;
    final double popupHeight = screenHeight * 0.5;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Container(
            width: popupWidth,
            height: popupHeight,
            padding: EdgeInsets.all(AppSizes.padding * 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                // Loading animation
                CustomLoadingIndicator(
                  type: LoadingType.pulsingGrid,
                  size: 80.w,
                  color: AppColors.primaryRed,
                ),
                SizedBox(height: AppSizes.verticalSpacingXL),
                // Animated message - takes available space
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _messages[_currentMessageIndex],
                        key: ValueKey<String>(_messages[_currentMessageIndex]),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppSizes.textL,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
                // Note hint if exists - fixed at bottom
                if (widget.note != null && widget.note!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.only(top: AppSizes.verticalSpacingM),
                    child: Text(
                      tr('recipes.loading.note_hint',
                          namedArgs: <String, String>{'note': widget.note!}),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        color: AppColors.textMedium,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

