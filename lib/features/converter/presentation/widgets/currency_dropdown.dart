import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:currency_converter/features/converter/domain/entities/currency.dart';
import 'package:flutter/material.dart';

class CurrencyDropdown extends StatelessWidget {
  const CurrencyDropdown({
    super.key,
    required this.currencies,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final List<Currency> currencies;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          CurrencySearchSheet(currencies: currencies, selected: value),
    );
    if (selected != null && selected != value) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: enabled ? () => _openPicker(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          enabled: enabled,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: SizedBox(
          height: 24,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class CurrencySearchSheet extends StatefulWidget {
  const CurrencySearchSheet({
    super.key,
    required this.currencies,
    required this.selected,
  });

  final List<Currency> currencies;
  final String selected;

  @override
  State<CurrencySearchSheet> createState() => _CurrencySearchSheetState();
}

class _CurrencySearchSheetState extends State<CurrencySearchSheet> {
  String _query = '';

  List<Currency> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.currencies;
    return widget.currencies
        .where(
          (c) =>
              c.code.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search currency',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No currencies found',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final currency = filtered[index];
                        final isSelected = currency.code == widget.selected;
                        return ListTile(
                          selected: isSelected,
                          leading: Text(
                            currency.code,
                            style: theme.textTheme.titleMedium,
                          ),
                          title: Text(currency.name),
                          trailing: isSelected ? const Icon(Icons.check) : null,
                          onTap: () => Navigator.pop(context, currency.code),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
