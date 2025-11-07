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
          RadioListTile<Locale>(
            title: Text(tr('turkish')),
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
          RadioListTile<Locale>(
            title: Text(tr('english')),
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

