import 'package:currency_converter/core/storage/app_database.dart';
import 'package:currency_converter/features/converter/data/datasources/converter_local_data_source.dart';
import 'package:currency_converter/features/converter/data/models/currency_model.dart';
import 'package:currency_converter/features/converter/data/models/exchange_rate_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late ConverterLocalDataSourceImpl dataSource;

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    dataSource = ConverterLocalDataSourceImpl(db);
  });

  tearDown(() => db.close());

  ExchangeRateModel rates(String base, DateTime date, double eur) =>
      ExchangeRateModel(base: base, date: date, rates: {'EUR': eur});

  test('caches currencies and replaces the previous list', () async {
    await dataSource.cacheCurrencies(const [
      CurrencyModel(code: 'USD', name: 'US Dollar'),
    ]);
    await dataSource.cacheCurrencies(const [
      CurrencyModel(code: 'EUR', name: 'Euro'),
      CurrencyModel(code: 'EGP', name: 'Egyptian Pound'),
    ]);

    final cached = await dataSource.getCachedCurrencies();

    expect(cached.map((c) => c.code), ['EGP', 'EUR']);
  });

  test('caching rates for same base overwrites the old table', () async {
    await dataSource.cacheRates(rates('USD', DateTime(2026, 9, 20), 0.8));
    await dataSource.cacheRates(rates('USD', DateTime(2026, 9, 24), 0.9));

    final cached = await dataSource.getCachedRates();

    expect(cached, hasLength(1));
    expect(cached.single.rates['EUR'], 0.9);
  });

  test('returns cached rate tables newest first', () async {
    await dataSource.cacheRates(rates('GBP', DateTime(2026, 9, 20), 1.1));
    await dataSource.cacheRates(rates('USD', DateTime(2026, 9, 24), 0.9));

    final cached = await dataSource.getCachedRates();

    expect(cached.map((r) => r.base), ['USD', 'GBP']);
  });
}
