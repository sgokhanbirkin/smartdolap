// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

/// Utility class for haptic feedback
/// Provides tactile feedback for user interactions
/// 
/// Usage:
/// ```dart
/// Haptics.light();  // For subtle interactions
/// Haptics.medium(); // For standard buttons
/// Haptics.heavy();  // For important actions
/// ```
class Haptics {
  /// Light impact - for subtle interactions
  /// Use for: switches, checkboxes, minor selections
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact - for standard buttons and actions
  /// Use for: regular buttons, list selections, tab changes
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for important or irreversible actions
  /// Use for: delete actions, confirmations, major changes
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click - for picker/slider changes
  /// Use for: scrolling through options, slider movements
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Success pattern - double tap for successful actions
  /// Use for: successful save, item added, task completed
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error pattern - strong double tap for errors
  /// Use for: failed actions, validation errors, network errors
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Long press - for drag and drop or context menus
  /// Use for: long press to reorder, long press to show menu
  static void longPress() {
    HapticFeedback.heavyImpact();
  }

  /// Vibrate - for notifications or alerts (platform specific)
  /// Use sparingly - can be annoying
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}

