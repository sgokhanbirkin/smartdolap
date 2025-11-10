import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/animated_pantry_card.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';

/// Widget that wraps a pantry item card with swipe-to-delete functionality
class PantryItemDismissibleWidget extends StatelessWidget {
  /// Creates a dismissible pantry item widget
  const PantryItemDismissibleWidget({
    required this.item,
    required this.userId,
    required this.index,
    required this.onTap,
    required this.onUndo,
    super.key,
  });

  /// Pantry item to display
  final PantryItem item;

  /// User ID
  final String userId;

  /// Item index for animation
  final int index;

  /// Callback when item is tapped
  final VoidCallback onTap;

  /// Callback when undo is pressed
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) => Dismissible(
    key: Key('pantry_item_${item.id}'),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: AppSizes.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius * 1.1),
      ),
      child: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.onError,
        size: AppSizes.iconXL,
      ),
    ),
    confirmDismiss: (DismissDirection direction) async {
      await HapticFeedback.mediumImpact();
      return true;
    },
    onDismissed: (DismissDirection direction) {
      context.read<PantryCubit>().remove(userId, item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('item_deleted'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          action: SnackBarAction(
            label: tr('undo'),
            textColor: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: onUndo,
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: AppSizes.padding,
            right: AppSizes.padding,
          ),
        ),
      );
    },
    child: AnimatedPantryCard(
      item: item,
      userId: userId,
      index: index,
      onTap: onTap,
      onQuantityChanged: (PantryItem updatedItem) {
        context.read<PantryCubit>().update(userId, updatedItem);
      },
    ),
  );
}

