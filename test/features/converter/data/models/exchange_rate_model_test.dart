import 'package:currency_converter/features/converter/data/models/exchange_rate_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final model = ExchangeRateModel(
    base: 'USD',
    date: DateTime(2026, 9, 24),
    rates: const {'EUR': 0.5, 'EGP': 50},
  );

  test('fromJson parses API response with int and double rates', () {
    final parsed = ExchangeRateModel.fromJson({
      'amount': 1.0,
      'base': 'USD',
      'date': '2026-09-24',
      'rates': {'EUR': 0.87974, 'IDR': 17933},
    });

    expect(parsed.base, 'USD');
    expect(parsed.date, DateTime(2026, 9, 24));
    expect(parsed.rates, {'EUR': 0.87974, 'IDR': 17933.0});
  });

  test('cache row round-trips', () {
    final row = model.toCacheRow(DateTime(2026, 9, 25));
    final restored = ExchangeRateModel.fromCacheRow(row);

    expect(restored.base, model.base);
    expect(restored.date, model.date);
    expect(restored.rates, model.rates);
  });

  group('rateFor', () {
    test('direct rate from base', () {
      expect(model.rateFor('USD', 'EUR'), 0.5);
    });

    test('inverse rate to base', () {
      expect(model.rateFor('EUR', 'USD'), 2);
    });

    test('cross rate between two non-base currencies', () {
      expect(model.rateFor('EUR', 'EGP'), 100);
    });

    test('same currency is 1', () {
      expect(model.rateFor('EUR', 'EUR'), 1);
    });

    test('unknown currency returns null', () {
      expect(model.rateFor('USD', 'JPY'), isNull);
    });
  });
}
