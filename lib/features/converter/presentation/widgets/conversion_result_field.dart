import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:currency_converter/core/utils/date_formatter.dart';
import 'package:currency_converter/core/widgets/app_details_card.dart';
import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversionResultField extends StatelessWidget {
  const ConversionResultField({super.key, required this.result});

  final AsyncValue<ConversionResult?> result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Converted',
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
      ),
      child: SizedBox(
        height: 24,
        child: switch (result) {
          AsyncData(:final value?) => Text(
            value.convertedAmount.toStringAsFixed(2),
            style: theme.textTheme.titleMedium,
          ),
          _ => Text(
            '—',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        },
      ),
    );
  }
}

class ConversionDetails extends StatelessWidget {
  const ConversionDetails({super.key, required this.result});

  final AsyncValue<ConversionResult?> result;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: switch (result) {
        AsyncError(:final error) => _ErrorBox(message: error.toString()),
        AsyncData(:final value?) => Column(
          children: [
            if (value.isCached) ...[
              _OfflineBanner(rateDate: value.date),
              const SizedBox(height: AppSpacing.sm),
            ],
            _details(value),
          ],
        ),
        _ => const SizedBox(width: double.infinity),
      },
    );
  }

  Widget _details(ConversionResult value) => AppDetailsCard(
    title: 'Conversion details',
    items: [
      AppDetailItem(
        'Amount',
        '${value.amount.toStringAsFixed(2)} ${value.from}',
      ),
      AppDetailItem(
        'Converted',
        '${value.convertedAmount.toStringAsFixed(2)} ${value.to}',
        emphasize: true,
      ),
      AppDetailItem(
        'Exchange rate',
        '1 ${value.from} = ${value.rate.toStringAsFixed(4)} ${value.to}',
      ),
      AppDetailItem(
        'Inverse rate',
        '1 ${value.to} = '
            '${(value.rate == 0 ? 0 : 1 / value.rate).toStringAsFixed(4)} '
            '${value.from}',
      ),
      AppDetailItem('Rate date', DateFormatter.date(value.date)),
      AppDetailItem('Source', value.isCached ? 'Cached (offline)' : 'Live'),
    ],
  );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.rateDate});

  final DateTime rateDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: scheme.onTertiaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'You are offline. Using last cached rates from '
              '${DateFormatter.date(rateDate)}.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
