// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/product/widgets/pantry_item_card.dart';

/// Animated wrapper for PantryItemCard with entrance animation
class AnimatedPantryCard extends StatelessWidget {
  const AnimatedPantryCard({
    required this.item,
    this.onTap,
    this.onQuantityChanged,
    this.userId,
    this.index = 0,
    super.key,
  });

  final PantryItem item;
  final VoidCallback? onTap;
  final ValueChanged<PantryItem>? onQuantityChanged;
  final String? userId;
  final int index;

  @override
  Widget build(BuildContext context) => PantryItemCard(
    item: item,
    onTap: onTap,
    onQuantityChanged: onQuantityChanged,
    userId: userId,
  )
      .animate()
      .fadeIn(
        duration: 300.ms,
        delay: (index * 30).ms,
        curve: Curves.easeOut,
      )
      .slideX(
        begin: -0.05,
        end: 0,
        duration: 300.ms,
        delay: (index * 30).ms,
        curve: Curves.easeOutCubic,
      );
}

