enum AppThemePreference { system, light, dark }

class AppSettings {
  const AppSettings({
    this.theme = AppThemePreference.system,
    this.defaultFrom = 'USD',
    this.defaultTo = 'EUR',
  });

  final AppThemePreference theme;
  final String defaultFrom;
  final String defaultTo;

  AppSettings copyWith({
    AppThemePreference? theme,
    String? defaultFrom,
    String? defaultTo,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      defaultFrom: defaultFrom ?? this.defaultFrom,
      defaultTo: defaultTo ?? this.defaultTo,
    );
  }
}
