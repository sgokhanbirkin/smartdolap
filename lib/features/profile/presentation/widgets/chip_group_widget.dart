import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Chip group widget for preferences
class ChipGroupWidget extends StatefulWidget {
  const ChipGroupWidget({
    required this.fieldKey,
    required this.title,
    required this.options,
    required this.hint,
    required this.selected,
    required this.customValues,
    required this.onSelected,
    required this.onAddCustom,
    required this.onRemoveCustom,
    super.key,
  });

  final String fieldKey;
  final String title;
  final List<String> options;
  final String hint;
  final String selected;
  final List<String> customValues;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onAddCustom;
  final ValueChanged<String> onRemoveCustom;

  @override
  State<ChipGroupWidget> createState() => _ChipGroupWidgetState();
}

class _ChipGroupWidgetState extends State<ChipGroupWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _addCustomValue() {
    final String value = _controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    if (widget.customValues.contains(value)) {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('profile_custom_${widget.fieldKey}_exists'))),
      );
      return;
    }
    _controller.clear();
    _toggleExpanded();
    widget.onAddCustom(value);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Text(widget.title, style: TextStyle(fontSize: AppSizes.textS)),
          const Spacer(),
          IconButton(
            icon: Icon(_isExpanded ? Icons.close : Icons.add),
            onPressed: _toggleExpanded,
          ),
        ],
      ),
      Text(
        widget.hint,
        style: TextStyle(
          fontSize: AppSizes.textXS,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      SizedBox(height: AppSizes.verticalSpacingS),
      Wrap(
        spacing: AppSizes.spacingS,
        runSpacing: AppSizes.verticalSpacingS / 2,
        children: <Widget>[
          ...widget.options.map(
            (String option) => ChoiceChip(
              label: Text(option),
              selected: option == widget.selected,
              onSelected: (_) => widget.onSelected(option),
            ),
          ),
          ...widget.customValues.map(
            (String option) => InputChip(
              label: Text(option),
              selected: option == widget.selected,
              onSelected: (_) => widget.onSelected(option),
              onDeleted: () => widget.onRemoveCustom(option),
            ),
          ),
        ],
      ),
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 250),
        crossFadeState: _isExpanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Padding(
          padding: EdgeInsets.only(top: AppSizes.verticalSpacingS),
          child: TextField(
            controller: _controller,
            style: TextStyle(fontSize: AppSizes.textM),
            decoration: InputDecoration(
              labelText: tr('profile_custom_${widget.fieldKey}_label'),
              hintText: tr('profile_custom_${widget.fieldKey}_hint'),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _addCustomValue,
              ),
            ),
            onSubmitted: (_) => _addCustomValue(),
          ),
        ),
      ),
      SizedBox(height: AppSizes.verticalSpacingM),
    ],
  );
}

