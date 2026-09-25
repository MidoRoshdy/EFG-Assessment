import 'package:currency_converter/features/settings/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  AppSettings load();

  Future<void> saveTheme(AppThemePreference theme);

  Future<void> saveDefaultFrom(String code);

  Future<void> saveDefaultTo(String code);
}
