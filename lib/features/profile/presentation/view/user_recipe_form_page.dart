import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Allows the user to create rich recipes with media.
class UserRecipeFormPage extends StatefulWidget {
  /// Builds the recipe form screen.
  const UserRecipeFormPage({super.key, this.onSubmit});

  /// Callback fired when the user saves the recipe.
  final Future<void> Function({
    required String title,
    required List<String> ingredients,
    required List<String> steps,
    String description,
    List<String>? tags,
    String? imagePath,
    String? videoPath,
  })? onSubmit;

  /// Provides the mutable state backing this widget.
  @override
  State<UserRecipeFormPage> createState() => _UserRecipeFormPageState();
}

class _UserRecipeFormPageState extends State<UserRecipeFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _ingredientCtrl = TextEditingController();
  final TextEditingController _stepCtrl = TextEditingController();
  final TextEditingController _tagCtrl = TextEditingController();

  final List<String> _ingredients = <String>[];
  final List<String> _steps = <String>[];
  final List<String> _tags = <String>[];

  File? _imageFile;
  File? _videoFile;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _ingredientCtrl.dispose();
    _stepCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia({required bool isVideo}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        if (isVideo) {
          _videoFile = File(file.path);
        } else {
          _imageFile = File(file.path);
        }
      });
    }
  }

  void _addItem(TextEditingController controller, List<String> target) {
    final String text = controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      target.add(text);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('profile_add_manual_recipe'))),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: tr('profile_recipe_title'),
                ),
                validator: (String? value) =>
                    value == null || value.trim().isEmpty
                        ? tr('invalid_name')
                        : null,
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(
                  labelText: tr('profile_recipe_desc'),
                ),
                maxLines: 3,
              ),
              SizedBox(height: AppSizes.verticalSpacingL),
              Text(tr('profile_recipe_ingredients')),
              SizedBox(height: AppSizes.verticalSpacingS),
              _chipInput(
                controller: _ingredientCtrl,
                placeholder: tr('profile_recipe_ingredient_hint'),
                items: _ingredients,
                onAdd: () => _addItem(_ingredientCtrl, _ingredients),
                onRemove: (String item) {
                  setState(() => _ingredients.remove(item));
                },
              ),
              SizedBox(height: AppSizes.verticalSpacingL),
              Text(tr('profile_recipe_steps')),
              SizedBox(height: AppSizes.verticalSpacingS),
              _chipInput(
                controller: _stepCtrl,
                placeholder: tr('profile_recipe_step_hint'),
                items: _steps,
                onAdd: () => _addItem(_stepCtrl, _steps),
                onRemove: (String item) {
                  setState(() => _steps.remove(item));
                },
                enumerated: true,
              ),
              SizedBox(height: AppSizes.verticalSpacingL),
              Text(tr('profile_recipe_tags')),
              SizedBox(height: AppSizes.verticalSpacingS),
              _chipInput(
                controller: _tagCtrl,
                placeholder: tr('profile_recipe_tag_hint'),
                items: _tags,
                onAdd: () => _addItem(_tagCtrl, _tags),
                onRemove: (String item) {
                  setState(() => _tags.remove(item));
                },
              ),
              SizedBox(height: AppSizes.verticalSpacingL),
              Text(tr('profile_media_section')),
              SizedBox(height: AppSizes.verticalSpacingS),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickMedia(isVideo: false),
                      icon: const Icon(Icons.image_outlined),
                      label: Text(tr('profile_pick_image')),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickMedia(isVideo: true),
                      icon: const Icon(Icons.videocam_outlined),
                      label: Text(tr('profile_pick_video')),
                    ),
                  ),
                ],
              ),
              if (_imageFile != null)
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.verticalSpacingS),
                  child: Image.file(_imageFile!, height: 120),
                ),
              if (_videoFile != null)
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.verticalSpacingS),
                  child: Text(
                    tr('profile_video_selected', namedArgs: <String, String>{
                      'path': _videoFile!.path.split('/').last,
                    }),
                  ),
                ),
              SizedBox(height: AppSizes.verticalSpacingL),
              FilledButton(
                onPressed: () async {
                  final NavigatorState navigator = Navigator.of(context);
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  if (widget.onSubmit != null) {
                    await widget.onSubmit!(
                      title: _title.text.trim(),
                      description: _description.text.trim(),
                      ingredients: _ingredients,
                      steps: _steps,
                      tags: _tags,
                      imagePath: _imageFile?.path,
                      videoPath: _videoFile?.path,
                    );
                  }
                  if (!mounted) {
                    return;
                  }
                  navigator.pop(true);
                },
                child: Text(tr('profile_save_btn')),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _chipInput({
    required TextEditingController controller,
    required String placeholder,
    required List<String> items,
    required VoidCallback onAdd,
    required ValueChanged<String> onRemove,
    bool enumerated = false,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: placeholder),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: onAdd,
              ),
            ],
          ),
          Wrap(
            spacing: AppSizes.spacingS,
            children: items.asMap().entries.map((MapEntry<int, String> entry) {
              final String text =
                  enumerated ? '${entry.key + 1}. ${entry.value}' : entry.value;
              return InputChip(
                label: Text(text),
                onDeleted: () => onRemove(entry.value),
              );
            }).toList(),
          ),
        ],
      );
}
