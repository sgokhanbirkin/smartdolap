import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/theme/theme_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/profile/presentation/widgets/language_dialog_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/theme_dialog_widget.dart';

/// Settings menu widget
class SettingsMenuWidget extends StatelessWidget {
  const SettingsMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness currentBrightness = Theme.of(context).brightness;
    final Locale currentLocale = Localizations.localeOf(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(AppSizes.padding),
            child: Text(
              tr('settings'),
              style: TextStyle(
                fontSize: AppSizes.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          // Language selection
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(tr('language')),
            subtitle: Text(
              currentLocale.languageCode == 'tr'
                  ? tr('turkish')
                  : tr('english'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => LanguageDialogWidget.show(context),
          ),
          // Theme selection
          ListTile(
            leading: Icon(
              currentBrightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            title: Text(tr('theme')),
            subtitle: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (BuildContext context, ThemeState state) {
                String themeText;
                switch (state.themeMode) {
                  case ThemeMode.light:
                    themeText = tr('light_theme');
                    break;
                  case ThemeMode.dark:
                    themeText = tr('dark_theme');
                    break;
                  case ThemeMode.system:
                    themeText = tr('system_theme');
                    break;
                }
                return Text(themeText);
              },
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ThemeDialogWidget.show(context),
          ),
          const Divider(height: 1),
          // Logout
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              tr('logout'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
          ),
          SizedBox(height: AppSizes.verticalSpacingS),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      builder: (BuildContext ctx) => const SettingsMenuWidget(),
    );
  }
}
