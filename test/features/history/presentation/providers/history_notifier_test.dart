import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/history/presentation/providers/history_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/test_app.dart';

void main() {
  test('loads saved records newest first', () async {
    final history = InMemoryHistoryRepository();
    await history.save(sampleRecord(to: 'EUR'));
    await history.save(sampleRecord(to: 'GBP'));
    final container = await createTestContainer(history: history);

    final records = await container.read(historyProvider.future);

    expect(records.map((r) => r.to), ['GBP', 'EUR']);
  });

  test('add prepends the saved record', () async {
    final history = InMemoryHistoryRepository();
    await history.save(sampleRecord(to: 'EUR'));
    final container = await createTestContainer(history: history);
    await container.read(historyProvider.future);

    await container.read(historyProvider.notifier).add(sampleRecord(to: 'GBP'));

    final records = container.read(historyProvider).value!;
    expect(records.map((r) => r.to), ['GBP', 'EUR']);
    expect(records.first.id, isNotNull);
  });

  test('delete removes record from state and storage', () async {
    final history = InMemoryHistoryRepository();
    final saved = await history.save(sampleRecord());
    final container = await createTestContainer(history: history);
    await container.read(historyProvider.future);

    await container.read(historyProvider.notifier).delete(saved.id!);

    expect(container.read(historyProvider).value, isEmpty);
    expect(history.records, isEmpty);
  });

  test('failed delete restores the record and rethrows', () async {
    final history = InMemoryHistoryRepository()..failOnDelete = true;
    final saved = await history.save(sampleRecord());
    final container = await createTestContainer(history: history);
    await container.read(historyProvider.future);

    await expectLater(
      container.read(historyProvider.notifier).delete(saved.id!),
      throwsA(isA<CacheFailure>()),
    );

    expect(container.read(historyProvider).value, hasLength(1));
  });
}
