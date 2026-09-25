import 'package:currency_converter/core/theme/app_spacing.dart';
import 'package:currency_converter/core/widgets/app_primary_button.dart';
import 'package:currency_converter/features/converter/domain/entities/currency.dart';
import 'package:currency_converter/features/converter/presentation/providers/converter_notifier.dart';
import 'package:currency_converter/features/converter/presentation/widgets/conversion_result_field.dart';
import 'package:currency_converter/features/converter/presentation/widgets/currency_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConverterForm extends ConsumerStatefulWidget {
  const ConverterForm({super.key, required this.currencies});

  final List<Currency> currencies;

  @override
  ConsumerState<ConverterForm> createState() => _ConverterFormState();
}

class _ConverterFormState extends ConsumerState<ConverterForm> {
  static const _currencyFieldWidth = 110.0;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter an amount';
    final amount = double.tryParse(text);
    if (amount == null) return 'Enter a valid number';
    if (amount <= 0) return 'Amount must be greater than 0';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(converterProvider.notifier)
        .convert(double.parse(_amountController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);
    final isLoading = state.result.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,4}'),
                    ),
                  ],
                  textInputAction: TextInputAction.done,
                  validator: _validateAmount,
                  onChanged: (_) => notifier.clearResult(),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: _currencyFieldWidth,
                child: CurrencyDropdown(
                  currencies: widget.currencies,
                  value: state.from,
                  onChanged: notifier.setFrom,
                  enabled: !isLoading,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Center(
              child: IconButton.filledTonal(
                tooltip: 'Swap currencies',
                onPressed: isLoading ? null : notifier.swap,
                icon: const Icon(Icons.swap_vert),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ConversionResultField(result: state.result)),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: _currencyFieldWidth,
                child: CurrencyDropdown(
                  currencies: widget.currencies,
                  value: state.to,
                  onChanged: notifier.setTo,
                  enabled: !isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Convert',
            isLoading: isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          ConversionDetails(result: state.result),
        ],
      ),
    );
  }
}
