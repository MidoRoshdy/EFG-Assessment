import 'package:currency_converter/core/error/exceptions.dart';
import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/converter/data/datasources/converter_local_data_source.dart';
import 'package:currency_converter/features/converter/data/datasources/converter_remote_data_source.dart';
import 'package:currency_converter/features/converter/data/models/currency_model.dart';
import 'package:currency_converter/features/converter/data/models/exchange_rate_model.dart';
import 'package:currency_converter/features/converter/data/repositories/converter_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemote implements ConverterRemoteDataSource {
  bool offline = false;
  bool serverError = false;

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    if (offline) throw const NetworkException();
    return const [
      CurrencyModel(code: 'EUR', name: 'Euro'),
      CurrencyModel(code: 'USD', name: 'US Dollar'),
    ];
  }

  @override
  Future<ExchangeRateModel> getLatestRates(String base) async {
    if (offline) throw const NetworkException();
    if (serverError) throw const ServerException('bad currency pair');
    return ExchangeRateModel(
      base: base,
      date: DateTime(2026, 9, 24),
      rates: const {'EUR': 0.5, 'EGP': 50},
    );
  }
}

class _InMemoryLocal implements ConverterLocalDataSource {
  final Map<String, ExchangeRateModel> rates = {};
  List<CurrencyModel> currencies = [];

  @override
  Future<void> cacheCurrencies(List<CurrencyModel> value) async =>
      currencies = value;

  @override
  Future<List<CurrencyModel>> getCachedCurrencies() async => currencies;

  @override
  Future<void> cacheRates(ExchangeRateModel value) async =>
      rates[value.base] = value;

  @override
  Future<List<ExchangeRateModel>> getCachedRates() async =>
      rates.values.toList();
}

void main() {
  late _FakeRemote remote;
  late _InMemoryLocal local;
  late ConverterRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemote();
    local = _InMemoryLocal();
    repository = ConverterRepositoryImpl(remote, local);
  });

  test('online conversion is live and caches the rates', () async {
    final result = await repository.convert(from: 'USD', to: 'EUR', amount: 10);

    expect(result.convertedAmount, 5);
    expect(result.isCached, isFalse);
    expect(local.rates.keys, contains('USD'));
  });

  test('offline conversion falls back to cached rates', () async {
    await repository.convert(from: 'USD', to: 'EUR', amount: 1);
    remote.offline = true;

    final result = await repository.convert(from: 'USD', to: 'EUR', amount: 4);

    expect(result.isCached, isTrue);
    expect(result.convertedAmount, 2);
    expect(result.date, DateTime(2026, 9, 24));
  });

  test(
    'offline conversion derives cross rate from another cached base',
    () async {
      await repository.convert(from: 'USD', to: 'EUR', amount: 1);
      remote.offline = true;

      final result = await repository.convert(
        from: 'EUR',
        to: 'EGP',
        amount: 1,
      );

      expect(result.isCached, isTrue);
      expect(result.rate, 100);
    },
  );

  test('offline without cache throws NetworkFailure', () async {
    remote.offline = true;

    expect(
      () => repository.convert(from: 'USD', to: 'EUR', amount: 1),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('server errors are not masked by cached rates', () async {
    await repository.convert(from: 'USD', to: 'EUR', amount: 1);
    remote.serverError = true;

    expect(
      () => repository.convert(from: 'USD', to: 'EUR', amount: 1),
      throwsA(isA<ServerFailure>()),
    );
  });

  test('currencies fall back to cache when offline', () async {
    await repository.getCurrencies();
    remote.offline = true;

    final currencies = await repository.getCurrencies();

    expect(currencies.map((c) => c.code), ['EUR', 'USD']);
  });
}
