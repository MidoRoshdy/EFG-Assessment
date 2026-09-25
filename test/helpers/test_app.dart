import 'package:currency_converter/app.dart';
import 'package:currency_converter/core/network/connectivity_providers.dart';
import 'package:currency_converter/core/storage/shared_preferences_provider.dart';
import 'package:currency_converter/features/converter/domain/repositories/converter_repository.dart';
import 'package:currency_converter/features/converter/presentation/providers/converter_providers.dart';
import 'package:currency_converter/features/history/domain/repositories/history_repository.dart';
import 'package:currency_converter/features/history/presentation/providers/history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

Future<SharedPreferences> mockPrefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Future<ProviderContainer> createTestContainer({
  Map<String, Object> prefs = const {},
  ConverterRepository? converter,
  HistoryRepository? history,
}) async {
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(await mockPrefs(prefs)),
      converterRepositoryProvider.overrideWithValue(
        converter ?? FakeConverterRepository(),
      ),
      historyRepositoryProvider.overrideWithValue(
        history ?? InMemoryHistoryRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

extension PumpApp on WidgetTester {
  Future<void> pumpApp({
    SharedPreferences? prefs,
    ConverterRepository? converter,
    HistoryRepository? history,
    Stream<bool>? connectivity,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith(
            (ref) => connectivity ?? Stream.value(true),
          ),
          sharedPreferencesProvider.overrideWithValue(
            prefs ?? await mockPrefs(),
          ),
          converterRepositoryProvider.overrideWithValue(
            converter ?? FakeConverterRepository(),
          ),
          historyRepositoryProvider.overrideWithValue(
            history ?? InMemoryHistoryRepository(),
          ),
        ],
        child: const App(),
      ),
    );
    await pumpAndSettle();
  }

  Future<void> openTab(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }

  Future<void> convertAmount(String amount) async {
    await enterText(find.byType(TextFormField), amount);
    await tap(find.text('Convert'));
    await pumpAndSettle();
  }
}

/// Wraps a single widget in a themed `MaterialApp` for isolated widget tests.
Widget wrapWidget(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);
