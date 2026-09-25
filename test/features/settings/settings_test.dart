import 'package:currency_converter/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:currency_converter/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:currency_converter/features/settings/domain/entities/app_settings.dart';
import 'package:currency_converter/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  group('SettingsRepositoryImpl', () {
    Future<SettingsRepositoryImpl> repository([
      Map<String, Object> values = const {},
    ]) async => SettingsRepositoryImpl(
      SettingsLocalDataSourceImpl(await mockPrefs(values)),
    );

    test('returns defaults when nothing is saved', () async {
      final settings = (await repository()).load();

      expect(settings.theme, AppThemePreference.system);
      expect(settings.defaultFrom, 'USD');
      expect(settings.defaultTo, 'EUR');
    });

    test('loads saved values', () async {
      final settings = (await repository({
        'settings.theme': 'dark',
        'settings.default_from': 'EGP',
        'settings.default_to': 'GBP',
      })).load();

      expect(settings.theme, AppThemePreference.dark);
      expect(settings.defaultFrom, 'EGP');
      expect(settings.defaultTo, 'GBP');
    });

    test('falls back to system theme for unknown stored value', () async {
      final settings = (await repository({'settings.theme': 'purple'})).load();

      expect(settings.theme, AppThemePreference.system);
    });
  });

  group('SettingsNotifier', () {
    test('persists changes and exposes matching ThemeMode', () async {
      final container = await createTestContainer();
      final notifier = container.read(settingsProvider.notifier);

      await notifier.setTheme(AppThemePreference.light);
      await notifier.setDefaultTo('EGP');

      expect(container.read(themeModeProvider), ThemeMode.light);
      final reloaded = container.read(settingsRepositoryProvider).load();
      expect(reloaded.theme, AppThemePreference.light);
      expect(reloaded.defaultTo, 'EGP');
    });
  });
}
