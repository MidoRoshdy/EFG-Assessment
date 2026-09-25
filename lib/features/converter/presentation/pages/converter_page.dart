import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:currency_converter/core/widgets/app_error_view.dart';
import 'package:currency_converter/core/widgets/app_loading_view.dart';
import 'package:currency_converter/features/converter/presentation/providers/converter_providers.dart';
import 'package:currency_converter/features/converter/presentation/widgets/converter_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConverterPage extends ConsumerWidget {
  const ConverterPage({super.key});

  static const _maxContentWidth = 560.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencies = ref.watch(currenciesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Converter')),
      body: SafeArea(
        child: switch (currencies) {
          AsyncData(:final value) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ConverterForm(currencies: value),
                  ),
                ),
              ),
            ),
          ),
          AsyncError(:final error) => AppErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(currenciesProvider),
          ),
          _ => const AppLoadingView(),
        },
      ),
    );
  }
}
