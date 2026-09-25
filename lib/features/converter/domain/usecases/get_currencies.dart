import 'package:currency_converter/features/converter/domain/entities/currency.dart';
import 'package:currency_converter/features/converter/domain/repositories/converter_repository.dart';

class GetCurrencies {
  const GetCurrencies(this._repository);

  final ConverterRepository _repository;

  Future<List<Currency>> call() => _repository.getCurrencies();
}
