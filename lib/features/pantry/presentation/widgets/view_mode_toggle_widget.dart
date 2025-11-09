import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/features/pantry/presentation/view/pantry_page.dart';

/// Widget for toggling between flat and grouped view modes
class ViewModeToggleWidget extends StatelessWidget {
  /// Creates a view mode toggle widget
  const ViewModeToggleWidget({
    required this.viewMode,
    required this.onViewModeChanged,
    super.key,
  });

  /// Current view mode
  final PantryViewMode viewMode;

  /// Callback when view mode changes
  final ValueChanged<PantryViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<PantryViewMode>(
    segments: <ButtonSegment<PantryViewMode>>[
      ButtonSegment<PantryViewMode>(
        value: PantryViewMode.flat,
        icon: const Icon(Icons.view_agenda_outlined, size: 16),
        label: Text(tr('pantry_view_flat')),
      ),
      ButtonSegment<PantryViewMode>(
        value: PantryViewMode.grouped,
        icon: const Icon(Icons.category_outlined, size: 16),
        label: Text(tr('pantry_view_grouped')),
      ),
    ],
    selected: <PantryViewMode>{viewMode},
    onSelectionChanged: (Set<PantryViewMode> value) =>
        onViewModeChanged(value.first),
  );
}

