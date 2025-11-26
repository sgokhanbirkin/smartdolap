import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/core/widgets/cached_image_widget.dart';

/// Widget for the name field with camera button,
/// image preview, and category chip
class PantryItemNameFieldWidget extends StatelessWidget {
  /// Creates a pantry item name field widget
  const PantryItemNameFieldWidget({
    required this.nameController,
    required this.category,
    required this.isProcessingPhoto,
    required this.isImageLoading,
    required this.onCameraPressed,
    required this.fieldDecoration,
    this.imageUrl,
    super.key,
  });

  /// Controller for the name text field
  final TextEditingController nameController;

  /// Currently selected category
  final String? category;

  /// Whether photo is being processed
  final bool isProcessingPhoto;

  /// Whether image is loading
  final bool isImageLoading;

  /// Image URL to display
  final String? imageUrl;

  /// Callback when camera button is pressed
  final VoidCallback onCameraPressed;

  /// Field decoration builder
  final InputDecoration Function(BuildContext, {String? hint}) fieldDecoration;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tr('name'),
            style: TextStyle(
              fontSize: AppSizes.textS,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizes.spacingXS),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: nameController,
                  style: TextStyle(fontSize: AppSizes.text),
                  decoration: fieldDecoration(
                    context,
                    hint: tr('pantry_item_placeholder'),
                  ),
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? tr('invalid_name')
                      : null,
                ),
              ),
              SizedBox(width: AppSizes.spacingS),
              IconButton.filled(
                onPressed: isProcessingPhoto ? null : onCameraPressed,
                icon: isProcessingPhoto
                    ? SizedBox(
                        width: AppSizes.iconS,
                        height: AppSizes.iconS,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
                tooltip: tr('take_photo'),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          if (category != null) ...<Widget>[
            SizedBox(height: AppSizes.verticalSpacingS),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingS,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    PantryCategoryHelper.iconFor(category!),
                    size: AppSizes.iconS,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Text(
                    PantryCategoryHelper.getLocalizedCategoryName(category!),
                    style: TextStyle(
                      fontSize: AppSizes.textS,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isImageLoading)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.spacingS),
              child: SizedBox(
                height: AppSizes.verticalSpacingXL,
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          else if (imageUrl != null)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.spacingS),
              child: CachedImageWidget(
                imageUrl: imageUrl,
                height: AppSizes.verticalSpacingXL * 1.5,
                width: double.infinity,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
            ),
        ],
      ),
    ),
  );
}
