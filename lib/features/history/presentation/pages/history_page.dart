import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:currency_converter/core/widgets/app_empty_view.dart';
import 'package:currency_converter/core/widgets/app_error_view.dart';
import 'package:currency_converter/core/widgets/app_loading_view.dart';
import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:currency_converter/features/history/presentation/pages/history_details_page.dart';
import 'package:currency_converter/features/history/presentation/providers/history_providers.dart';
import 'package:currency_converter/features/history/presentation/widgets/history_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static const _maxContentWidth = 720.0;

  void _openDetails(BuildContext context, ConversionRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryDetailsPage(record: record),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ConversionRecord record,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(historyProvider.notifier).delete(record.id!);
      messenger.showSnackBar(
        const SnackBar(content: Text('Conversion deleted')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete conversion')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: history.when(
          loading: () => const AppLoadingView(),
          error: (error, _) => AppErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(historyProvider),
          ),
          data: (records) {
            if (records.isEmpty) {
              return const AppEmptyView(
                icon: Icons.history,
                title: 'No conversions yet',
                message: 'Your completed conversions will appear here.',
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Dismissible(
                      key: ValueKey(record.id),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => _delete(context, ref, record),
                      child: HistoryListItem(
                        record: record,
                        onTap: () => _openDetails(context, record),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: scheme.error,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Icon(Icons.delete_outline, color: scheme.onError),
    );
  }
}
