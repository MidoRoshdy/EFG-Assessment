import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/converter/presentation/providers/converter_providers.dart';
import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:currency_converter/features/history/presentation/providers/history_providers.dart';
import 'package:currency_converter/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConverterState {
  const ConverterState({
    required this.from,
    required this.to,
    this.result = const AsyncData(null),
  });

  final String from;
  final String to;
  final AsyncValue<ConversionResult?> result;

  ConverterState copyWith({
    String? from,
    String? to,
    AsyncValue<ConversionResult?>? result,
  }) {
    return ConverterState(
      from: from ?? this.from,
      to: to ?? this.to,
      result: result ?? this.result,
    );
  }
}

final converterProvider = NotifierProvider<ConverterNotifier, ConverterState>(
  ConverterNotifier.new,
);

class ConverterNotifier extends Notifier<ConverterState> {
  @override
  ConverterState build() {
    ref.listen(settingsProvider.select((s) => s.defaultFrom), (_, code) {
      setFrom(code);
    });
    ref.listen(settingsProvider.select((s) => s.defaultTo), (_, code) {
      setTo(code);
    });

    final settings = ref.read(settingsProvider);
    return ConverterState(from: settings.defaultFrom, to: settings.defaultTo);
  }

  void setFrom(String code) =>
      state = state.copyWith(from: code, result: const AsyncData(null));

  void setTo(String code) =>
      state = state.copyWith(to: code, result: const AsyncData(null));

  void swap() => state = state.copyWith(
    from: state.to,
    to: state.from,
    result: const AsyncData(null),
  );

  void clearResult() {
    if (state.result.value != null || state.result.hasError) {
      state = state.copyWith(result: const AsyncData(null));
    }
  }

  Future<void> convert(double amount) async {
    final from = state.from;
    final to = state.to;
    state = state.copyWith(result: const AsyncLoading());
    final convert = ref.read(convertCurrencyProvider);
    final result = await AsyncValue.guard(
      () => convert(from: from, to: to, amount: amount),
    );
    if (!ref.mounted || state.from != from || state.to != to) return;
    state = state.copyWith(result: result);

    final value = result.value;
    if (value != null) await _saveToHistory(value);
  }

  Future<void> _saveToHistory(ConversionResult result) async {
    try {
      await ref
          .read(historyProvider.notifier)
          .add(
            ConversionRecord(
              from: result.from,
              to: result.to,
              amount: result.amount,
              rate: result.rate,
              rateDate: result.date,
              createdAt: DateTime.now(),
              isCached: result.isCached,
            ),
          );
    } catch (_) {
      // A failed history write must not fail the conversion itself.
    }
  }
}
