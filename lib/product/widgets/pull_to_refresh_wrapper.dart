// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:smartdolap/core/utils/haptics.dart';

/// Pull-to-refresh wrapper widget
/// Provides native pull-to-refresh experience with haptic feedback
/// 
/// Usage:
/// ```dart
/// PullToRefreshWrapper(
///   onRefresh: () async {
///     await loadData();
///   },
///   child: ListView(...),
/// )
/// ```
class PullToRefreshWrapper extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? indicatorColor;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;

  const PullToRefreshWrapper({
    required this.onRefresh,
    required this.child,
    this.indicatorColor,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    super.key,
  });

  Future<void> _handleRefresh() async {
    // Haptic feedback for pull-to-refresh
    Haptics.light();
    
    try {
      await onRefresh();
      
      // Success haptic
      Haptics.success();
    } on Object catch (_) {
      // Error haptic
      Haptics.error();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: indicatorColor ?? Theme.of(context).colorScheme.primary,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      displacement: displacement,
      edgeOffset: edgeOffset,
      child: child,
    );
  }
}

