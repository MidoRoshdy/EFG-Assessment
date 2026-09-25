import 'package:currency_converter/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:currency_converter/features/settings/domain/entities/app_settings.dart';
import 'package:currency_converter/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._local);

  final SettingsLocalDataSource _local;

  @override
  AppSettings load() {
    const defaults = AppSettings();
    return AppSettings(
      theme:
          AppThemePreference.values.asNameMap()[_local.getTheme()] ??
          defaults.theme,
      defaultFrom: _local.getDefaultFrom() ?? defaults.defaultFrom,
      defaultTo: _local.getDefaultTo() ?? defaults.defaultTo,
    );
  }

  @override
  Future<void> saveTheme(AppThemePreference theme) =>
      _local.setTheme(theme.name);

  @override
  Future<void> saveDefaultFrom(String code) => _local.setDefaultFrom(code);

  @override
  Future<void> saveDefaultTo(String code) => _local.setDefaultTo(code);
}
