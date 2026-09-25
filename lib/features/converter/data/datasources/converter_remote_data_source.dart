import 'package:currency_converter/core/constants/api_constants.dart';
import 'package:currency_converter/core/network/api_client.dart';
import 'package:currency_converter/features/converter/data/models/currency_model.dart';
import 'package:currency_converter/features/converter/data/models/exchange_rate_model.dart';

abstract interface class ConverterRemoteDataSource {
  Future<List<CurrencyModel>> getCurrencies();

  Future<ExchangeRateModel> getLatestRates(String base);
}

class ConverterRemoteDataSourceImpl implements ConverterRemoteDataSource {
  const ConverterRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    final json = await _client.get(ApiConstants.currencies);
    return CurrencyModel.fromJsonMap(json);
  }

  @override
  Future<ExchangeRateModel> getLatestRates(String base) async {
    final json = await _client.get(ApiConstants.latest, query: {'from': base});
    return ExchangeRateModel.fromJson(json);
  }
}
