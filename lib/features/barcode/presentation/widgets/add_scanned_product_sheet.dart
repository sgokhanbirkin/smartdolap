// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/services/feedback/feedback_service.dart';
import 'package:smartdolap/core/utils/haptics.dart';
import 'package:smartdolap/core/widgets/cached_image_widget.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_view_model.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/expiry_date_picker_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/unit_dropdown_widget.dart';

/// Bottom sheet for adding scanned product to pantry
/// Allows user to review product info and customize before adding
class AddScannedProductSheet extends StatefulWidget {
  final ScannedProduct product;

  const AddScannedProductSheet({
    required this.product,
    super.key,
  });

  @override
  State<AddScannedProductSheet> createState() => _AddScannedProductSheetState();
}

class _AddScannedProductSheetState extends State<AddScannedProductSheet> {
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  DateTime? _expiryDate;
  bool _isAdding = false;

  static const List<String> _unitOptions = <String>[
    'adet',
    'kg',
    'g',
    'L',
    'ml',
    'paket',
    'kutu',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _unitController = TextEditingController(text: 'adet');

    // Try to extract unit from package quantity
    _extractUnitFromPackage();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _extractUnitFromPackage() {
    final String? packageQty = widget.product.packageQuantity;
    if (packageQty == null) return;

    // Extract unit from strings like "500g", "1L", "250ml"
    final RegExp regex = RegExp(r'(\d+\.?\d*)\s*([a-zA-Z]+)');
    final RegExpMatch? match = regex.firstMatch(packageQty);

    if (match != null) {
      final String? qty = match.group(1);
      final String? unit = match.group(2);

      if (qty != null) {
        _quantityController.text = qty;
      }

      if (unit != null) {
        // Normalize unit
        final String normalizedUnit = _normalizeUnit(unit);
        if (_isValidUnit(normalizedUnit)) {
          _unitController.text = normalizedUnit;
        }
      }
    }
  }

  String _normalizeUnit(String unit) {
    final String lower = unit.toLowerCase();
    if (lower == 'g' || lower == 'gr' || lower == 'gram') return 'g';
    if (lower == 'kg' || lower == 'kilo') return 'kg';
    if (lower == 'l' || lower == 'lt' || lower == 'litre') return 'L';
    if (lower == 'ml' || lower == 'mililitre') return 'ml';
    return 'adet';
  }

  bool _isValidUnit(String unit) {
    return _unitOptions.contains(unit);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Drag handle
              _buildDragHandle(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product header
                      _buildProductHeader(),

                      SizedBox(height: AppSizes.verticalSpacingL),

                      // Quantity section
                      _buildQuantitySection(),

                      SizedBox(height: AppSizes.verticalSpacingL),

                      // Expiry date section
                      _buildExpirySection(),

                      SizedBox(height: AppSizes.verticalSpacingL),

                      // Nutrition info (if available)
                      if (widget.product.nutrition?.hasData == true)
                        _buildNutritionInfo(),

                      SizedBox(height: AppSizes.verticalSpacingXXL),

                      // Add button
                      _buildAddButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        if (widget.product.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: CachedImageWidget(
              imageUrl: widget.product.imageUrl,
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
            ),
          ),

        SizedBox(width: AppSizes.spacingM),

        // Product info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.product.brand != null) ...[
                SizedBox(height: 4.h),
                Text(
                  widget.product.brand!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
              if (widget.product.category != null) ...[
                SizedBox(height: 4.h),
                Chip(
                  label: Text(widget.product.category!),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quantity'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSizes.spacingS),
        Row(
          children: [
            // Quantity input
            Expanded(
              flex: 2,
              child: TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '1',
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingM,
                    vertical: AppSizes.spacingM,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.spacingM),
            // Unit dropdown
            Expanded(
              child: UnitDropdownWidget(
                unitController: _unitController,
                unitOptions: _unitOptions,
                wrapInCard: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpirySection() {
    return ExpiryDatePickerWidget(
      expiryDate: _expiryDate,
      onDateSelected: (DateTime? date) {
        setState(() => _expiryDate = date);
        if (date != null) {
          Haptics.light();
        }
      },
    );
  }

  Widget _buildNutritionInfo() {
    final NutritionInfo? nutrition = widget.product.nutrition;
    if (nutrition == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'nutrition_info_per_100g'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSizes.spacingS),
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.padding),
            child: Column(
              children: [
                if (nutrition.caloriesPer100g != null)
                  _buildNutritionRow(
                    'calories'.tr(),
                    '${nutrition.caloriesPer100g!.toInt()} kcal',
                    Icons.local_fire_department,
                  ),
                if (nutrition.proteinPer100g != null)
                  _buildNutritionRow(
                    'protein'.tr(),
                    '${nutrition.proteinPer100g}g',
                    Icons.egg,
                  ),
                if (nutrition.carbsPer100g != null)
                  _buildNutritionRow(
                    'carbs'.tr(),
                    '${nutrition.carbsPer100g}g',
                    Icons.rice_bowl,
                  ),
                if (nutrition.fatPer100g != null)
                  _buildNutritionRow(
                    'fat'.tr(),
                    '${nutrition.fatPer100g}g',
                    Icons.water_drop,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp),
          SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isAdding ? null : _addToPantry,
        icon: _isAdding
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_shopping_cart),
        label: Text(
          _isAdding ? 'adding'.tr() : 'add_to_pantry'.tr(),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  Future<void> _addToPantry() async {
    if (_isAdding) return;

    final double? quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      sl<IFeedbackService>().showError(context, 'invalid_quantity');
      return;
    }

    setState(() => _isAdding = true);

    try {
      final AuthCubit authCubit = context.read<AuthCubit>();
      final String? userId = authCubit.state.maybeWhen(
        authenticated: (user) => user.id,
        orElse: () => null,
      );
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final PantryItem item = PantryItem(
        id: '',
        name: widget.product.name,
        quantity: quantity,
        unit: _unitController.text.trim(),
        expiryDate: _expiryDate,
        imageUrl: widget.product.imageUrl,
        category: widget.product.category,
        ingredients: <Ingredient>[],
      );

      await context.read<PantryViewModel>().add(userId, item);

      if (mounted) {
        Haptics.success();
        sl<IFeedbackService>().showSuccess(context, 'item_added_successfully');
        Navigator.pop(context);
        Navigator.pop(context); // Also close scanner
      }
    } on Exception catch (e) {
      if (mounted) {
        Haptics.error();
        sl<IFeedbackService>().showError(
          context,
          'failed_to_add_item',
          details: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }
}

