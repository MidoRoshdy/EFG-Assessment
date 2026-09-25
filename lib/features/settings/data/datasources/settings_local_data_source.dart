import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SettingsLocalDataSource {
  String? getTheme();
  String? getDefaultFrom();
  String? getDefaultTo();

  Future<void> setTheme(String value);
  Future<void> setDefaultFrom(String code);
  Future<void> setDefaultTo(String code);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  const SettingsLocalDataSourceImpl(this._prefs);

  static const _themeKey = 'settings.theme';
  static const _defaultFromKey = 'settings.default_from';
  static const _defaultToKey = 'settings.default_to';

  final SharedPreferences _prefs;

  @override
  String? getTheme() => _prefs.getString(_themeKey);

  @override
  String? getDefaultFrom() => _prefs.getString(_defaultFromKey);

  @override
  String? getDefaultTo() => _prefs.getString(_defaultToKey);

  @override
  Future<void> setTheme(String value) => _prefs.setString(_themeKey, value);

  @override
  Future<void> setDefaultFrom(String code) =>
      _prefs.setString(_defaultFromKey, code);

  @override
  Future<void> setDefaultTo(String code) =>
      _prefs.setString(_defaultToKey, code);
}
