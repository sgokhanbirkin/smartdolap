import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// Theme state
class ThemeState {
  /// Creates a theme state
  const ThemeState(this.themeMode);

  /// Current theme mode
  final ThemeMode themeMode;
}

/// Theme Cubit for managing app theme
class ThemeCubit extends Cubit<ThemeState> {
  /// Creates a ThemeCubit
  ThemeCubit() : super(const ThemeState(ThemeMode.system)) {
    _loadTheme();
  }

  static const String _themeBoxName = 'app_settings';
  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final Box<dynamic> box = Hive.isBoxOpen(_themeBoxName)
          ? Hive.box<dynamic>(_themeBoxName)
          : await Hive.openBox<dynamic>(_themeBoxName);

      final String? savedTheme = box.get(_themeKey) as String?;
      if (savedTheme != null) {
        final ThemeMode mode = ThemeMode.values.firstWhere(
          (ThemeMode e) => e.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
        emit(ThemeState(mode));
      }
    } on Exception {
      // Ignore errors, use default
    }
  }

  /// Sets the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(ThemeState(mode));
    try {
      final Box<dynamic> box = Hive.isBoxOpen(_themeBoxName)
          ? Hive.box<dynamic>(_themeBoxName)
          : await Hive.openBox<dynamic>(_themeBoxName);
      await box.put(_themeKey, mode.toString());
    } on Exception {
      // Ignore errors
    }
  }
}
