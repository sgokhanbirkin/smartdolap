// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/theme/theme_cubit.dart';

/// Theme dialog widget
class ThemeDialogWidget extends StatelessWidget {
  const ThemeDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeCubit themeCubit = context.read<ThemeCubit>();
    final ThemeMode currentThemeMode = themeCubit.state.themeMode;

    return AlertDialog(
      title: Text(tr('theme')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(tr('light_theme')),
            leading: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeCubit.setThemeMode(value);
                  Navigator.pop(context);
                  Navigator.pop(context); // Close settings menu too
                }
              },
            ),
            onTap: () {
              themeCubit.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(tr('dark_theme')),
            leading: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeCubit.setThemeMode(value);
                  Navigator.pop(context);
                  Navigator.pop(context); // Close settings menu too
                }
              },
            ),
            onTap: () {
              themeCubit.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(tr('system_theme')),
            leading: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeCubit.setThemeMode(value);
                  Navigator.pop(context);
                  Navigator.pop(context); // Close settings menu too
                }
              },
            ),
            onTap: () {
              themeCubit.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => const ThemeDialogWidget(),
    );
  }
}
