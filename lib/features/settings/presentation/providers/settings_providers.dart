import 'package:currency_converter/core/storage/shared_preferences_provider.dart';
import 'package:currency_converter/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:currency_converter/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:currency_converter/features/settings/domain/entities/app_settings.dart';
import 'package:currency_converter/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSourceImpl(ref.watch(sharedPreferencesProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider)),
);

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final theme = ref.watch(settingsProvider.select((s) => s.theme));
  return switch (theme) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
});

class SettingsNotifier extends Notifier<AppSettings> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> setTheme(AppThemePreference theme) async {
    state = state.copyWith(theme: theme);
    await _repository.saveTheme(theme);
  }

  Future<void> setDefaultFrom(String code) async {
    state = state.copyWith(defaultFrom: code);
    await _repository.saveDefaultFrom(code);
  }

  Future<void> setDefaultTo(String code) async {
    state = state.copyWith(defaultTo: code);
    await _repository.saveDefaultTo(code);
  }
}
