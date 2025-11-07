// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/product/widgets/recipe_card.dart';

/// Animated wrapper for RecipeCard with hover/press effects
class AnimatedRecipeCard extends StatelessWidget {
  const AnimatedRecipeCard({
    required this.recipe,
    this.onTap,
    this.index = 0,
    super.key,
  });

  final Recipe recipe;
  final VoidCallback? onTap;
  final int index;

  @override
  Widget build(BuildContext context) => RecipeCard(recipe: recipe, onTap: onTap)
      .animate()
      .fadeIn(duration: 400.ms, delay: (index * 50).ms, curve: Curves.easeOut)
      .slideY(
        begin: 0.1,
        end: 0,
        duration: 400.ms,
        delay: (index * 50).ms,
        curve: Curves.easeOutCubic,
      )
      .scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 400.ms,
        delay: (index * 50).ms,
        curve: Curves.easeOutBack,
      );
}
