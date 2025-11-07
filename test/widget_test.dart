import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/main.dart';

class _FakeAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() async {
    await sl.reset();
    final _FakeAuthCubit fakeAuthCubit = _FakeAuthCubit();
    when(() => fakeAuthCubit.state).thenReturn(const AuthState.initial());
    whenListen(fakeAuthCubit, const Stream<AuthState>.empty());
    sl.registerFactory<AuthCubit>(() => fakeAuthCubit);
  });

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
