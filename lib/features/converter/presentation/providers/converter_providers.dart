import 'package:currency_converter/core/network/network_providers.dart';
import 'package:currency_converter/core/storage/app_database.dart';
import 'package:currency_converter/features/converter/data/datasources/converter_local_data_source.dart';
import 'package:currency_converter/features/converter/data/datasources/converter_remote_data_source.dart';
import 'package:currency_converter/features/converter/data/repositories/converter_repository_impl.dart';
import 'package:currency_converter/features/converter/domain/entities/currency.dart';
import 'package:currency_converter/features/converter/domain/repositories/converter_repository.dart';
import 'package:currency_converter/features/converter/domain/usecases/convert_currency.dart';
import 'package:currency_converter/features/converter/domain/usecases/get_currencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final converterRemoteDataSourceProvider = Provider<ConverterRemoteDataSource>(
  (ref) => ConverterRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final converterLocalDataSourceProvider = Provider<ConverterLocalDataSource>(
  (ref) => ConverterLocalDataSourceImpl(ref.watch(databaseProvider)),
);

final converterRepositoryProvider = Provider<ConverterRepository>(
  (ref) => ConverterRepositoryImpl(
    ref.watch(converterRemoteDataSourceProvider),
    ref.watch(converterLocalDataSourceProvider),
  ),
);

final getCurrenciesProvider = Provider<GetCurrencies>(
  (ref) => GetCurrencies(ref.watch(converterRepositoryProvider)),
);

final convertCurrencyProvider = Provider<ConvertCurrency>(
  (ref) => ConvertCurrency(ref.watch(converterRepositoryProvider)),
);

final currenciesProvider = FutureProvider<List<Currency>>(
  (ref) => ref.watch(getCurrenciesProvider).call(),
);
