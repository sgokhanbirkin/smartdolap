// ignore_for_file: public_member_api_docs

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Optimized cached image widget with placeholder and error handling
/// Features:
/// - Automatic caching (memory + disk)
/// - Shimmer placeholder effect
/// - Error fallback with icon
/// - Configurable fit and aspect ratio
class CachedImageWidget extends StatelessWidget {
  /// Cached image widget constructor
  const CachedImageWidget({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.aspectRatio,
    this.borderRadius,
    this.placeholderIcon = Icons.image,
    this.errorIcon = Icons.broken_image,
    this.placeholderColor,
    this.errorColor,
    super.key,
  });

  /// Image URL to load
  final String? imageUrl;

  /// Image width
  final double? width;

  /// Image height
  final double? height;

  /// Box fit mode
  final BoxFit fit;

  /// Aspect ratio (if provided, height will be calculated from width)
  final double? aspectRatio;

  /// Border radius for clipping
  final BorderRadius? borderRadius;

  /// Placeholder icon
  final IconData placeholderIcon;

  /// Error icon
  final IconData errorIcon;

  /// Placeholder background color
  final Color? placeholderColor;

  /// Error background color
  final Color? errorColor;

  @override
  Widget build(BuildContext context) {
    final Color defaultPlaceholderColor =
        placeholderColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final Color defaultErrorColor =
        errorColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;

    // If no image URL, show placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(
        context,
        defaultPlaceholderColor,
        placeholderIcon,
      );
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      // Placeholder with shimmer effect
      placeholder: (BuildContext context, String url) => _buildShimmerPlaceholder(
        context,
        defaultPlaceholderColor,
      ),
      // Error widget
      errorWidget: (BuildContext context, String url, Object error) {
        debugPrint('CachedImageWidget: Image load error for $url - $error');
        return _buildErrorWidget(
          context,
          defaultErrorColor,
          errorIcon,
        );
      },
      // Cache configuration
      memCacheWidth: width?.isFinite == true ? width?.toInt() : null,
      memCacheHeight: height?.isFinite == true ? height?.toInt() : null,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );

    // Apply aspect ratio if provided
    if (aspectRatio != null) {
      imageWidget = AspectRatio(
        aspectRatio: aspectRatio!,
        child: imageWidget,
      );
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Build shimmer placeholder effect
  Widget _buildShimmerPlaceholder(BuildContext context, Color backgroundColor) => Shimmer.fromColors(
      baseColor: backgroundColor,
      highlightColor: backgroundColor.withValues(alpha: 0.3),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: backgroundColor,
      ),
    );

  /// Build static placeholder
  Widget _buildPlaceholder(
    BuildContext context,
    Color backgroundColor,
    IconData icon,
  ) {
    Widget placeholder = Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: backgroundColor,
      child: Icon(
        icon,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.4 : height! * 0.4)
            : AppSizes.iconXL,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );

    if (aspectRatio != null) {
      placeholder = AspectRatio(
        aspectRatio: aspectRatio!,
        child: placeholder,
      );
    }

    if (borderRadius != null) {
      placeholder = ClipRRect(
        borderRadius: borderRadius!,
        child: placeholder,
      );
    }

    return placeholder;
  }

  /// Build error widget
  Widget _buildErrorWidget(
    BuildContext context,
    Color backgroundColor,
    IconData icon,
  ) {
    Widget errorWidget = Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: backgroundColor,
      child: Icon(
        icon,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.4 : height! * 0.4)
            : AppSizes.iconXL,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );

    if (aspectRatio != null) {
      errorWidget = AspectRatio(
        aspectRatio: aspectRatio!,
        child: errorWidget,
      );
    }

    if (borderRadius != null) {
      errorWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: errorWidget,
      );
    }

    return errorWidget;
  }
}

