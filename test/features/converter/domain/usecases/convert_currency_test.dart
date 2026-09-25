import 'package:currency_converter/features/converter/domain/usecases/convert_currency.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late FakeConverterRepository repository;
  late ConvertCurrency convert;

  setUp(() {
    repository = FakeConverterRepository(rate: 0.5);
    convert = ConvertCurrency(repository);
  });

  test('delegates to repository for different currencies', () async {
    final result = await convert(from: 'USD', to: 'EUR', amount: 10);

    expect(result.convertedAmount, 5);
    expect(repository.convertCalls, 1);
  });

  test('same currency returns rate 1 without calling repository', () async {
    final result = await convert(from: 'USD', to: 'USD', amount: 10);

    expect(result.rate, 1);
    expect(result.convertedAmount, 10);
    expect(repository.convertCalls, 0);
  });
}
