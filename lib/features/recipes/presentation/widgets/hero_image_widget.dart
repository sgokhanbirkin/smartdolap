import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/cached_image_widget.dart';

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
    return CachedImageWidget(
      imageUrl: imageUrl,
      aspectRatio: 16 / 9,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      placeholderIcon: Icons.restaurant,
      errorIcon: Icons.restaurant,
    );
  }
}

