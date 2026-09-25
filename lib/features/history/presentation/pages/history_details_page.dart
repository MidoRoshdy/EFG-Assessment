import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:currency_converter/core/utils/date_formatter.dart';
import 'package:currency_converter/core/widgets/app_details_card.dart';
import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:currency_converter/features/history/presentation/providers/history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryDetailsPage extends ConsumerWidget {
  const HistoryDetailsPage({super.key, required this.record});

  final ConversionRecord record;

  static const _maxContentWidth = 560.0;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversion?'),
        content: const Text('This entry will be removed from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(historyProvider.notifier).delete(record.id!);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = record;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion'),
        actions: [
          if (r.id != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${r.amount.toStringAsFixed(2)} ${r.from}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const Icon(Icons.arrow_downward),
                Text(
                  '${r.convertedAmount.toStringAsFixed(2)} ${r.to}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppDetailsCard(
                  title: 'Conversion details',
                  items: [
                    AppDetailItem('From', r.from),
                    AppDetailItem('To', r.to),
                    AppDetailItem(
                      'Amount',
                      '${r.amount.toStringAsFixed(2)} ${r.from}',
                    ),
                    AppDetailItem(
                      'Converted',
                      '${r.convertedAmount.toStringAsFixed(2)} ${r.to}',
                      emphasize: true,
                    ),
                    AppDetailItem(
                      'Exchange rate',
                      '1 ${r.from} = ${r.rate.toStringAsFixed(4)} ${r.to}',
                    ),
                    AppDetailItem(
                      'Inverse rate',
                      '1 ${r.to} = ${r.inverseRate.toStringAsFixed(4)} ${r.from}',
                    ),
                    AppDetailItem('Rate date', DateFormatter.date(r.rateDate)),
                    AppDetailItem(
                      'Converted at',
                      DateFormatter.dateTime(r.createdAt),
                    ),
                    AppDetailItem(
                      'Source',
                      r.isCached ? 'Cached (offline)' : 'Live',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
