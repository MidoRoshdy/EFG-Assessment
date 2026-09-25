import 'package:currency_converter/features/converter/data/models/currency_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJsonMap parses and sorts currencies by code', () {
    final currencies = CurrencyModel.fromJsonMap({
      'USD': 'US Dollar',
      'EGP': 'Egyptian Pound',
      'EUR': 'Euro',
    });

    expect(currencies.map((c) => c.code), ['EGP', 'EUR', 'USD']);
    expect(currencies.first.name, 'Egyptian Pound');
  });
}
