import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:currency_converter/core/utils/date_formatter.dart';
import 'package:currency_converter/core/widgets/app_list_item.dart';
import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:flutter/material.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem({super.key, required this.record, this.onTap});

  final ConversionRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppListItem(
      leading: CircleAvatar(
        backgroundColor: record.isCached
            ? scheme.tertiaryContainer
            : scheme.primaryContainer,
        foregroundColor: record.isCached
            ? scheme.onTertiaryContainer
            : scheme.onPrimaryContainer,
        child: Icon(
          record.isCached ? Icons.cloud_off : Icons.currency_exchange,
          size: 20,
        ),
      ),
      title:
          '${record.amount.toStringAsFixed(2)} ${record.from} → '
          '${record.convertedAmount.toStringAsFixed(2)} ${record.to}',
      subtitle:
          '${DateFormatter.dateTime(record.createdAt)}  ·  '
          '${record.isCached ? 'Cached (offline)' : 'Live'}',
      trailing: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.xs),
        child: Icon(Icons.chevron_right),
      ),
      onTap: onTap,
    );
  }
}
