import 'package:currency_converter/core/error/exceptions.dart';
import 'package:currency_converter/core/storage/app_database.dart';
import 'package:currency_converter/features/converter/data/models/currency_model.dart';
import 'package:currency_converter/features/converter/data/models/exchange_rate_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class ConverterLocalDataSource {
  Future<void> cacheCurrencies(List<CurrencyModel> currencies);

  Future<List<CurrencyModel>> getCachedCurrencies();

  Future<void> cacheRates(ExchangeRateModel rates);

  Future<List<ExchangeRateModel>> getCachedRates();
}

class ConverterLocalDataSourceImpl implements ConverterLocalDataSource {
  const ConverterLocalDataSourceImpl(this._db);

  final Database _db;

  static const _ratesTable = AppDatabase.ratesCacheTable;
  static const _currenciesTable = AppDatabase.currenciesCacheTable;

  @override
  Future<void> cacheCurrencies(List<CurrencyModel> currencies) =>
      _guard(() async {
        final batch = _db.batch()..delete(_currenciesTable);
        for (final c in currencies) {
          batch.insert(_currenciesTable, {'code': c.code, 'name': c.name});
        }
        await batch.commit(noResult: true);
      });

  @override
  Future<List<CurrencyModel>> getCachedCurrencies() => _guard(() async {
    final rows = await _db.query(_currenciesTable, orderBy: 'code');
    return rows
        .map(
          (r) => CurrencyModel(
            code: r['code'] as String,
            name: r['name'] as String,
          ),
        )
        .toList();
  });

  @override
  Future<void> cacheRates(ExchangeRateModel rates) => _guard(
    () => _db.insert(
      _ratesTable,
      rates.toCacheRow(DateTime.now()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ),
  );

  @override
  Future<List<ExchangeRateModel>> getCachedRates() => _guard(() async {
    final rows = await _db.query(
      _ratesTable,
      orderBy: 'rate_date DESC, fetched_at DESC',
    );
    return rows.map(ExchangeRateModel.fromCacheRow).toList();
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (e) {
      throw CacheException(e.toString());
    }
  }
}
