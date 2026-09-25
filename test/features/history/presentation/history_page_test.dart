import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  testWidgets('shows empty state when there is no history', (tester) async {
    await tester.pumpApp();

    await tester.openTab(Icons.history_outlined);

    expect(find.text('No conversions yet'), findsOneWidget);
  });

  testWidgets('saves conversion and opens its details', (tester) async {
    final history = InMemoryHistoryRepository();
    await tester.pumpApp(history: history);

    await tester.convertAmount('10');
    expect(history.records, hasLength(1));

    await tester.openTab(Icons.history_outlined);
    expect(find.text('10.00 USD → 5.00 EUR'), findsOneWidget);
    expect(find.textContaining('Live'), findsOneWidget);

    await tester.tap(find.text('10.00 USD → 5.00 EUR'));
    await tester.pumpAndSettle();

    expect(find.text('Conversion'), findsOneWidget);
    expect(find.text('1 USD = 0.5000 EUR'), findsOneWidget);
    expect(find.text('Converted at'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('offline entry is marked as cached', (tester) async {
    final history = InMemoryHistoryRepository();
    await history.save(sampleRecord(isCached: true));
    await tester.pumpApp(history: history);

    await tester.openTab(Icons.history_outlined);

    expect(find.textContaining('Cached (offline)'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);

    await tester.tap(find.text('1.00 USD → 48.00 EGP'));
    await tester.pumpAndSettle();

    expect(find.text('Cached (offline)'), findsOneWidget);
  });

  testWidgets('swipe deletes an entry', (tester) async {
    final history = InMemoryHistoryRepository();
    await history.save(sampleRecord());
    await tester.pumpApp(history: history);
    await tester.openTab(Icons.history_outlined);

    await tester.drag(find.text('1.00 USD → 48.00 EGP'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(history.records, isEmpty);
    expect(find.text('Conversion deleted'), findsOneWidget);
    expect(find.text('No conversions yet'), findsOneWidget);
  });

  testWidgets('deletes from details page after confirmation', (tester) async {
    final history = InMemoryHistoryRepository();
    await history.save(sampleRecord());
    await tester.pumpApp(history: history);
    await tester.openTab(Icons.history_outlined);

    await tester.tap(find.text('1.00 USD → 48.00 EGP'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete conversion?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(history.records, isEmpty);
    expect(find.text('No conversions yet'), findsOneWidget);
  });

  testWidgets('cancelling delete keeps the entry', (tester) async {
    final history = InMemoryHistoryRepository();
    await history.save(sampleRecord());
    await tester.pumpApp(history: history);
    await tester.openTab(Icons.history_outlined);

    await tester.tap(find.text('1.00 USD → 48.00 EGP'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(history.records, hasLength(1));
    expect(find.text('Conversion'), findsOneWidget);
  });
}
