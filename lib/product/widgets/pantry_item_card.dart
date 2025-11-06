// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

class PantryItemCard extends StatelessWidget {
  const PantryItemCard({required this.item, this.onTap, super.key});

  final PantryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0.95, end: 1.0),
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOut,
    builder: (BuildContext context, double scale, Widget? child) =>
        Transform.scale(scale: scale, child: child),
    child: Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(item.name, style: TextStyle(fontSize: AppSizes.text)),
        subtitle: Text(
          '${item.quantity} ${item.unit}'.trim(),
          style: TextStyle(fontSize: AppSizes.textS),
        ),
        trailing: item.expiryDate != null
            ? Text(
                _formatDate(item.expiryDate!),
                style: TextStyle(fontSize: AppSizes.textS),
              )
            : null,
      ),
    ),
  );

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
          .toString();
}
