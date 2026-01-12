// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Language dialog widget
class LanguageDialogWidget extends StatelessWidget {
  const LanguageDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Locale currentLocale = Localizations.localeOf(context);

    return AlertDialog(
      title: Text(tr('language')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(tr('turkish')),
            leading: Radio<Locale>(
              value: const Locale('tr', 'TR'),
              groupValue: currentLocale,
              onChanged: (Locale? value) {
                if (value != null) {
                  context.setLocale(value);
                  Navigator.pop(context);
                  Navigator.pop(context); // Close settings menu too
                }
              },
            ),
            onTap: () {
              context.setLocale(const Locale('tr', 'TR'));
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(tr('english')),
            leading: Radio<Locale>(
              value: const Locale('en', 'US'),
              groupValue: currentLocale,
              onChanged: (Locale? value) {
                if (value != null) {
                  context.setLocale(value);
                  Navigator.pop(context);
                  Navigator.pop(context); // Close settings menu too
                }
              },
            ),
            onTap: () {
              context.setLocale(const Locale('en', 'US'));
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
      builder: (BuildContext ctx) => const LanguageDialogWidget(),
    );
  }
}
