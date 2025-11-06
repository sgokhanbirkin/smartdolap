import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smartdolap/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr', 'TR'),
        child: const SmartDolapApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
