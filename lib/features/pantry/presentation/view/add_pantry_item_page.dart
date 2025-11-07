// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs, use_build_context_synchronously, always_put_control_body_on_new_line
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/core/utils/quantity_formatter.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/camera_ingredient_dialog_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/category_selector_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/expiry_date_picker_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_item_name_field_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_item_quantity_unit_widget.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/product/services/storage/i_storage_service.dart';

class AddPantryItemPage extends StatefulWidget {
  const AddPantryItemPage({required this.userId, super.key});

  final String userId;

  @override
  State<AddPantryItemPage> createState() => _AddPantryItemPageState();
}

class _AddPantryItemPageState extends State<AddPantryItemPage> {
  static const List<String> _unitOptions = <String>[
    'adet',
    'kg',
    'g',
    'lt',
    'ml',
    'paket',
    'kutu',
    'demet',
    'tane',
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _qty = TextEditingController(text: '1');
  final TextEditingController _unit = TextEditingController();
  DateTime? _expiry;
  String? _category;
  bool _categoryLocked = false;
  bool _isCategorizing = false;
  String? _suggestedCategory;
  Timer? _categoryDebounce;
  final ImageLookupService _imageLookup = sl<ImageLookupService>();
  String? _imageUrl;
  bool _isImageLoading = false;
  Timer? _imageDebounce;
  bool _isProcessingPhoto = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;

    setState(() => _isProcessingPhoto = true);

    try {
      final File imageFile = File(image.path);
      final List<int> imageBytes = await imageFile.readAsBytes();

      // Upload to Firebase Storage
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('unknown_error')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessingPhoto = false);
        return;
      }

      final IStorageService storageService = sl<IStorageService>();
      final String imageUrl = await storageService.uploadPantryItemPhoto(
        userId: userId,
        itemId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageBytes: Uint8List.fromList(imageBytes),
      );

      // Parse ingredients from image using OpenAI Vision
      final IOpenAIService openAIService = sl<IOpenAIService>();
      final List<Ingredient> detectedIngredients = await openAIService
          .parseFridgeImage(Uint8List.fromList(imageBytes));

      if (!mounted) return;

      if (detectedIngredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('no_items_found')),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isProcessingPhoto = false);
        return;
      }

      // Show dialog to select ingredient
      final Ingredient? selectedIngredient =
          await CameraIngredientDialogWidget.show(context, detectedIngredients);

      if (!mounted || selectedIngredient == null) {
        setState(() => _isProcessingPhoto = false);
        return;
      }

      // Fill form with selected ingredient
      setState(() {
        _name.text = selectedIngredient.name;
        _qty.text = selectedIngredient.quantity.toString();
        _unit.text = selectedIngredient.unit;
        _imageUrl = imageUrl;
        _isProcessingPhoto = false;
      });

      // Trigger category detection
      await _onNameChanged();
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('unknown_error')),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isProcessingPhoto = false);
    }
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _category = category;
      _categoryLocked = category != null;
    });
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _categoryDebounce?.cancel();
    _imageDebounce?.cancel();
    _name.dispose();
    _qty.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _onNameChanged() async {
    _categoryDebounce?.cancel();
    final String name = _name.text.trim();
    if (name.length < 2) {
      setState(() {
        _suggestedCategory = null;
        _category = null;
        _isCategorizing = false;
        _categoryLocked = false;
        _imageUrl = null;
        _isImageLoading = false;
      });
      return;
    }

    final String quickGuess = PantryCategoryHelper.guess(name);
    setState(() {
      _suggestedCategory = quickGuess;
      if (!_categoryLocked) {
        _category = quickGuess;
      }
    });

    _categoryDebounce = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _isCategorizing = true);
      try {
        final String cat = await sl<IOpenAIService>().categorizeItem(name);
        if (!mounted || _name.text.trim() != name) {
          return;
        }
        setState(() {
          _isCategorizing = false;
          _suggestedCategory = cat;
          if (!_categoryLocked) {
            _category = cat;
          }
        });
      } on Exception catch (_) {
        if (mounted) {
          setState(() => _isCategorizing = false);
        }
      }
    });

    _imageDebounce?.cancel();
    _imageDebounce = Timer(const Duration(milliseconds: 700), () async {
      setState(() => _isImageLoading = true);
      final String? url = await _imageLookup.search('$name food photo');
      if (!mounted || _name.text.trim() != name) {
        return;
      }
      setState(() {
        _isImageLoading = false;
        if (url != null) {
          _imageUrl = url;
        }
      });
    });
  }

  InputDecoration _fieldDecoration(BuildContext context, {String? hint}) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingS + 2,
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('add_item')), elevation: 0),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PantryItemNameFieldWidget(
                nameController: _name,
                category: _category,
                isProcessingPhoto: _isProcessingPhoto,
                isImageLoading: _isImageLoading,
                imageUrl: _imageUrl,
                onCameraPressed: _pickImageFromCamera,
                fieldDecoration: _fieldDecoration,
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              CategorySelectorWidget(
                selectedCategory: _category,
                isCategorizing: _isCategorizing,
                suggestedCategory: _suggestedCategory,
                onCategorySelected: _onCategorySelected,
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              PantryItemQuantityUnitWidget(
                quantityController: _qty,
                unitController: _unit,
                unitOptions: _unitOptions,
                fieldDecoration: _fieldDecoration,
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              ExpiryDatePickerWidget(
                expiryDate: _expiry,
                onDateSelected: (DateTime? date) =>
                    setState(() => _expiry = date),
              ),
              SizedBox(height: AppSizes.verticalSpacingXL),
              // Save button
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final double qty =
                      double.tryParse(_qty.text.replaceAll(',', '.')) ?? 1.0;
                  // Floating-point precision sorununu önlemek için yuvarlama
                  final double roundedQty = QuantityFormatter.roundQuantity(qty, _unit.text.trim());
                  final String? normalizedCategory = _category == null
                      ? null
                      : PantryCategoryHelper.normalize(_category);
                  final PantryItem item = PantryItem(
                    id: '',
                    name: _name.text.trim(),
                    quantity: roundedQty,
                    unit: _unit.text.trim(),
                    expiryDate: _expiry,
                    category: normalizedCategory,
                    imageUrl: _imageUrl,
                  );
                  await context.read<PantryCubit>().add(widget.userId, item);
                  if (mounted) Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
                  ),
                ),
                child: Text(
                  tr('save'),
                  style: TextStyle(
                    fontSize: AppSizes.textM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
