import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppDetailItem {
  const AppDetailItem(this.label, this.value, {this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;
}

class AppDetailsCard extends StatelessWidget {
  const AppDetailsCard({
    super.key,
    required this.title,
    required this.items,
    this.icon = Icons.receipt_long,
  });

  final String title;
  final IconData icon;
  final List<AppDetailItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: AppSpacing.md, color: scheme.outlineVariant),
          for (final item in items) _DetailRow(item: item),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.item});

  final AppDetailItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.value,
              textAlign: TextAlign.end,
              style: item.emphasize
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
