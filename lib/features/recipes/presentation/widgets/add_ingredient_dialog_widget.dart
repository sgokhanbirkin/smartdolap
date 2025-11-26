import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/category_selector_widget.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';

/// Dialog for adding a new ingredient with AI-powered category suggestion
class AddIngredientDialogWidget extends StatefulWidget {
  /// Creates an add ingredient dialog widget
  const AddIngredientDialogWidget({super.key});

  @override
  State<AddIngredientDialogWidget> createState() =>
      _AddIngredientDialogWidgetState();
}

class _AddIngredientDialogWidgetState extends State<AddIngredientDialogWidget> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategory;
  String? _suggestedCategory;
  bool _isCategorizing = false;
  bool _categoryLocked = false;
  Timer? _categoryDebounce;

  @override
  void dispose() {
    _categoryDebounce?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    _categoryDebounce?.cancel();
    final String name = value.trim();
    if (name.length < 2) {
      setState(() {
        _suggestedCategory = null;
        _selectedCategory = null;
        _isCategorizing = false;
        _categoryLocked = false;
      });
      return;
    }

    // Quick guess
    final String quickGuess = PantryCategoryHelper.guess(name);
    setState(() {
      _suggestedCategory = quickGuess;
      if (!_categoryLocked) {
        _selectedCategory = quickGuess;
      }
    });

    // AI category suggestion
    _categoryDebounce = Timer(
      const Duration(milliseconds: 600),
      () async {
        setState(() => _isCategorizing = true);
        try {
          final String cat = await sl<IOpenAIService>().categorizeItem(name);
          if (_nameController.text.trim() != name || !mounted) {
            return;
          }
          setState(() {
            _isCategorizing = false;
            _suggestedCategory = cat;
            if (!_categoryLocked) {
              _selectedCategory = cat;
            }
          });
        } on Exception catch (_) {
          if (mounted) {
            setState(() => _isCategorizing = false);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Text(tr('add_ingredient')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: tr('ingredient_name'),
                border: const OutlineInputBorder(),
                hintText: tr('pantry_item_placeholder'),
              ),
              autofocus: true,
              onChanged: _onNameChanged,
            ),
            SizedBox(height: AppSizes.spacingM),
            CategorySelectorWidget(
              selectedCategory: _selectedCategory,
              isCategorizing: _isCategorizing,
              suggestedCategory: _suggestedCategory,
              onCategorySelected: (String? value) {
                setState(() {
                  _selectedCategory = value;
                  _categoryLocked = value != null;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _categoryDebounce?.cancel();
            Navigator.of(context).pop(<String, String?>{});
          },
          child: Text(tr('cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              _categoryDebounce?.cancel();
              Navigator.of(context).pop(<String, String?>{
                'name': _nameController.text.trim(),
                'category': _selectedCategory,
              });
            }
          },
          child: Text(tr('add')),
        ),
      ],
    );
}

