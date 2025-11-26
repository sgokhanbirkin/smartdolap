import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Widget for note input field
class NoteFieldWidget extends StatelessWidget {
  /// Creates a note field widget
  const NoteFieldWidget({
    required this.controller,
    super.key,
  });

  /// Text editing controller for note input
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tr('note'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSizes.spacingS),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: tr('note_hint'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.note_outlined),
          ),
          maxLines: 3,
          maxLength: 200,
        ),
      ],
    );
}

