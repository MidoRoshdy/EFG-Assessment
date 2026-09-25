import 'dart:async';

import 'package:currency_converter/core/error/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  group('validation', () {
    testWidgets('requires an amount', (tester) async {
      await tester.pumpApp();

      await tester.tap(find.text('Convert'));
      await tester.pumpAndSettle();

      expect(find.text('Enter an amount'), findsOneWidget);
    });

    testWidgets('rejects zero', (tester) async {
      final converter = FakeConverterRepository();
      await tester.pumpApp(converter: converter);

      await tester.convertAmount('0');

      expect(find.text('Amount must be greater than 0'), findsOneWidget);
      expect(converter.convertCalls, 0);
    });

    testWidgets('input formatter blocks letters and extra decimals', (
      tester,
    ) async {
      await tester.pumpApp();

      await tester.enterText(find.byType(TextFormField), '12.34567abc');
      await tester.pump();

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.controller.text, isNot(contains('abc')));
    });
  });

  testWidgets('converts and shows result with details', (tester) async {
    await tester.pumpApp();

    await tester.convertAmount('10');

    expect(find.text('5.00'), findsOneWidget);
    expect(find.text('Conversion details'), findsOneWidget);
    expect(find.text('10.00 USD'), findsOneWidget);
    expect(find.text('5.00 EUR'), findsOneWidget);
    expect(find.text('1 USD = 0.5000 EUR'), findsOneWidget);
    expect(find.text('1 EUR = 2.0000 USD'), findsOneWidget);
    expect(find.text('2026-09-24'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('shows loading only in button and locks inputs', (tester) async {
    final converter = FakeConverterRepository()..gate = Completer<void>();
    await tester.pumpApp(converter: converter);

    await tester.enterText(find.byType(TextFormField), '10');
    await tester.tap(find.text('Convert'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );

    converter.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('5.00'), findsOneWidget);
  });

  testWidgets('shows offline banner when using cached rates', (tester) async {
    await tester.pumpApp(
      converter: FakeConverterRepository(
        isCached: true,
        rateDate: DateTime(2026, 9, 20),
      ),
    );

    await tester.convertAmount('10');

    expect(
      find.text('You are offline. Using last cached rates from 2026-09-20.'),
      findsOneWidget,
    );
    expect(find.text('Cached (offline)'), findsOneWidget);
  });

  testWidgets('shows conversion error message', (tester) async {
    await tester.pumpApp(
      converter: FakeConverterRepository(
        convertError: const NetworkFailure(
          'No internet connection. No cached rates for USD → EUR',
        ),
      ),
    );

    await tester.convertAmount('10');

    expect(
      find.text('No internet connection. No cached rates for USD → EUR'),
      findsOneWidget,
    );
    expect(find.text('Conversion details'), findsNothing);
  });

  testWidgets('shows retry when currencies fail to load, then recovers', (
    tester,
  ) async {
    final converter = FakeConverterRepository(
      currenciesError: const NetworkFailure('No internet connection'),
    );
    await tester.pumpApp(converter: converter);

    expect(find.text('No internet connection'), findsOneWidget);

    converter.currenciesError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Convert'), findsOneWidget);
  });

  testWidgets('swap button exchanges currencies', (tester) async {
    await tester.pumpApp();

    await tester.tap(find.byTooltip('Swap currencies'));
    await tester.pumpAndSettle();

    final from = tester.getTopLeft(find.text('EUR'));
    final to = tester.getTopLeft(find.text('USD'));
    expect(from.dy, lessThan(to.dy));
  });

  testWidgets('searches and selects a currency from the picker', (
    tester,
  ) async {
    await tester.pumpApp();

    await tester.tap(find.text('EUR'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Search currency'),
      'dollar',
    );
    await tester.pumpAndSettle();

    expect(find.text('Euro'), findsNothing);
    await tester.tap(find.text('US Dollar'));
    await tester.pumpAndSettle();

    expect(find.text('USD'), findsNWidgets(2));
  });

  testWidgets('picker shows empty state for no matches', (tester) async {
    await tester.pumpApp();

    await tester.tap(find.text('EUR'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Search currency'),
      'zzz',
    );
    await tester.pumpAndSettle();

    expect(find.text('No currencies found'), findsOneWidget);
  });

  testWidgets('starts with saved default currencies', (tester) async {
    await tester.pumpApp(
      prefs: await mockPrefs({
        'settings.default_from': 'EGP',
        'settings.default_to': 'USD',
      }),
    );

    expect(find.text('EGP'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
  });
}
