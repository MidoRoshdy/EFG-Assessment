import 'dart:async';

import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/converter/presentation/providers/converter_notifier.dart';
import 'package:currency_converter/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/test_app.dart';

void main() {
  test('starts with default currencies from settings', () async {
    final container = await createTestContainer(
      prefs: {'settings.default_from': 'EGP', 'settings.default_to': 'USD'},
    );

    final state = container.read(converterProvider);

    expect(state.from, 'EGP');
    expect(state.to, 'USD');
    expect(state.result.value, isNull);
  });

  test('swap exchanges currencies and clears result', () async {
    final container = await createTestContainer();
    final notifier = container.read(converterProvider.notifier);
    await notifier.convert(10);

    notifier.swap();

    final state = container.read(converterProvider);
    expect((state.from, state.to), ('EUR', 'USD'));
    expect(state.result.value, isNull);
  });

  test('successful conversion stores result and saves to history', () async {
    final history = InMemoryHistoryRepository();
    final container = await createTestContainer(
      converter: FakeConverterRepository(isCached: true),
      history: history,
    );

    await container.read(converterProvider.notifier).convert(10);

    final result = container.read(converterProvider).result.value!;
    expect(result.convertedAmount, 5);
    expect(history.records.single.amount, 10);
    expect(history.records.single.isCached, isTrue);
  });

  test('failed conversion exposes error and saves nothing', () async {
    final history = InMemoryHistoryRepository();
    final container = await createTestContainer(
      converter: FakeConverterRepository(
        convertError: const NetworkFailure('No internet connection'),
      ),
      history: history,
    );

    await container.read(converterProvider.notifier).convert(10);

    final result = container.read(converterProvider).result;
    expect(result.error, isA<NetworkFailure>());
    expect(history.records, isEmpty);
  });

  test('ignores stale response when currency changes mid-request', () async {
    final converter = FakeConverterRepository()..gate = Completer<void>();
    final container = await createTestContainer(converter: converter);
    final notifier = container.read(converterProvider.notifier);

    final pending = notifier.convert(10);
    expect(container.read(converterProvider).result.isLoading, isTrue);

    notifier.setTo('EGP');
    converter.gate!.complete();
    await pending;

    final state = container.read(converterProvider);
    expect(state.to, 'EGP');
    expect(state.result.value, isNull);
  });

  test('changing default currency in settings updates converter', () async {
    final container = await createTestContainer();
    container.read(converterProvider);

    await container.read(settingsProvider.notifier).setDefaultFrom('EGP');

    expect(container.read(converterProvider).from, 'EGP');
  });
}
