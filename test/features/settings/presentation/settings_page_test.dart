import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('switches to dark mode and persists it', (tester) async {
    final prefs = await mockPrefs();
    await tester.pumpApp(prefs: prefs);
    await tester.openTab(Icons.settings_outlined);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(prefs.getString('settings.theme'), 'dark');
  });

  testWidgets('shows default currencies with their names', (tester) async {
    await tester.pumpApp();
    await tester.openTab(Icons.settings_outlined);

    expect(find.text('USD — US Dollar'), findsOneWidget);
    expect(find.text('EUR — Euro'), findsOneWidget);
  });

  testWidgets('changing default currency updates the converter', (
    tester,
  ) async {
    final prefs = await mockPrefs();
    await tester.pumpApp(prefs: prefs);
    await tester.openTab(Icons.settings_outlined);

    await tester.tap(find.text('From'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Egyptian Pound'));
    await tester.pumpAndSettle();

    expect(find.text('EGP — Egyptian Pound'), findsOneWidget);
    expect(prefs.getString('settings.default_from'), 'EGP');

    await tester.openTab(Icons.currency_exchange_outlined);
    expect(find.text('EGP'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
  });
}
