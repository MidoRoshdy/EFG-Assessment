import 'package:currency_converter/core/error/exceptions.dart';
import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/converter/data/datasources/converter_local_data_source.dart';
import 'package:currency_converter/features/converter/data/datasources/converter_remote_data_source.dart';
import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/converter/domain/entities/currency.dart';
import 'package:currency_converter/features/converter/domain/repositories/converter_repository.dart';

class ConverterRepositoryImpl implements ConverterRepository {
  const ConverterRepositoryImpl(this._remote, this._local);

  final ConverterRemoteDataSource _remote;
  final ConverterLocalDataSource _local;

  @override
  Future<List<Currency>> getCurrencies() => _guard(() async {
    try {
      final currencies = await _remote.getCurrencies();
      await _ignoreCacheErrors(() => _local.cacheCurrencies(currencies));
      return currencies;
    } on NetworkException {
      final cached = await _local.getCachedCurrencies();
      if (cached.isEmpty) rethrow;
      return cached;
    }
  });

  @override
  Future<ConversionResult> convert({
    required String from,
    required String to,
    required double amount,
  }) => _guard(() async {
    try {
      final rates = await _remote.getLatestRates(from);
      await _ignoreCacheErrors(() => _local.cacheRates(rates));
      final rate = rates.rateFor(from, to);
      if (rate == null) {
        throw ServerException('No rate available for $from → $to');
      }
      return ConversionResult(
        from: from,
        to: to,
        amount: amount,
        rate: rate,
        date: rates.date,
      );
    } on NetworkException catch (e) {
      final cached = await _local.getCachedRates();
      final exact = cached.where((r) => r.base == from);
      for (final table in [...exact, ...cached]) {
        final rate = table.rateFor(from, to);
        if (rate != null) {
          return ConversionResult(
            from: from,
            to: to,
            amount: amount,
            rate: rate,
            date: table.date,
            isCached: true,
          );
        }
      }
      throw NetworkException('${e.message}. No cached rates for $from → $to');
    }
  });

  Future<void> _ignoreCacheErrors(Future<void> Function() action) async {
    try {
      await action();
    } on CacheException {
      // Caching is best-effort; the live data is still valid.
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
