import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/converter/domain/entities/currency.dart';

abstract interface class ConverterRepository {
  Future<List<Currency>> getCurrencies();

  Future<ConversionResult> convert({
    required String from,
    required String to,
    required double amount,
  });
}
