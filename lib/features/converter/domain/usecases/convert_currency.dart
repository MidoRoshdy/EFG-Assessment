import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/converter/domain/repositories/converter_repository.dart';

class ConvertCurrency {
  const ConvertCurrency(this._repository);

  final ConverterRepository _repository;

  Future<ConversionResult> call({
    required String from,
    required String to,
    required double amount,
  }) {
    if (from == to) {
      return Future.value(
        ConversionResult(
          from: from,
          to: to,
          amount: amount,
          rate: 1,
          date: DateTime.now(),
        ),
      );
    }
    return _repository.convert(from: from, to: to, amount: amount);
  }
}
