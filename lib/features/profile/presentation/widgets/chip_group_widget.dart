import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: AppSizes.iconS,
              ),
              SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Text(
                  tr('profile_custom_${widget.fieldKey}_exists'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: AppSizes.padding,
            right: AppSizes.padding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    _controller.clear();
    _toggleExpanded();
    widget.onAddCustom(value);
  }

  /// Localize option value based on field key
  String _localizeOption(String option) {
    // Try to find translation key for this option
    final String translationKey = 'profile_${widget.fieldKey}_$option';
    try {
      final String translated = tr(translationKey);
      // If translation exists and is different from the key, use it
      if (translated != translationKey) {
        return translated;
      }
    } catch (e) {
      // Translation not found, use original option
    }
    // Capitalize first letter if no translation found
    if (option.isEmpty) return option;
    return option[0].toUpperCase() + option.substring(1);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(
              fontSize: AppSizes.textM,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
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
          height: 1.4,
        ),
      ),
      SizedBox(height: AppSizes.verticalSpacingS),
      Wrap(
        spacing: AppSizes.spacingS,
        runSpacing: AppSizes.verticalSpacingS / 2,
        children: <Widget>[
          ...widget.options.map(
            (String option) => ChoiceChip(
              label: Text(_localizeOption(option)),
              selected: option == widget.selected,
              onSelected: (_) => widget.onSelected(option),
            ),
          ),
          ...widget.customValues.map(
            (String option) => InputChip(
              label: Text(_localizeOption(option)),
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

