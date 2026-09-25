import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:currency_converter/features/converter/domain/entities/currency.dart';
import 'package:currency_converter/features/converter/presentation/providers/converter_providers.dart';
import 'package:currency_converter/features/converter/presentation/widgets/currency_dropdown.dart';
import 'package:currency_converter/features/settings/domain/entities/app_settings.dart';
import 'package:currency_converter/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _maxContentWidth = 560.0;

  Future<void> _pickCurrency(
    BuildContext context, {
    required List<Currency> currencies,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          CurrencySearchSheet(currencies: currencies, selected: selected),
    );
    if (code != null) onSelected(code);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final currencies = ref.watch(currenciesProvider).value;
    final theme = Theme.of(context);

    String label(String code) {
      final name = currencies
          ?.where((c) => c.code == code)
          .map((c) => c.name)
          .firstOrNull;
      return name == null ? code : '$code — $name';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text('Appearance', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<AppThemePreference>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemePreference.system,
                      icon: Icon(Icons.brightness_auto),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: AppThemePreference.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: AppThemePreference.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {settings.theme},
                  onSelectionChanged: (s) => notifier.setTheme(s.first),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Default currencies', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Used every time the app opens.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.north_east),
                        title: const Text('From'),
                        subtitle: Text(label(settings.defaultFrom)),
                        trailing: const Icon(Icons.chevron_right),
                        enabled: currencies != null,
                        onTap: () => _pickCurrency(
                          context,
                          currencies: currencies!,
                          selected: settings.defaultFrom,
                          onSelected: notifier.setDefaultFrom,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.south_west),
                        title: const Text('To'),
                        subtitle: Text(label(settings.defaultTo)),
                        trailing: const Icon(Icons.chevron_right),
                        enabled: currencies != null,
                        onTap: () => _pickCurrency(
                          context,
                          currencies: currencies!,
                          selected: settings.defaultTo,
                          onSelected: notifier.setDefaultTo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
