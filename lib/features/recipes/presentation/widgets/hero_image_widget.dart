import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Hero image widget for recipe detail page
class HeroImageWidget extends StatelessWidget {
  const HeroImageWidget({required this.imageUrl, super.key});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        height: AppSizes.verticalSpacingXXL * 6.875,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.restaurant,
          size: AppSizes.iconXL,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, Object error, StackTrace? stackTrace) {
            debugPrint('Resim yüklenemedi: $imageUrl - $error');
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.restaurant,
                size: AppSizes.iconXL,
              ),
            );
          },
        ),
      ),
    );
  }
}

