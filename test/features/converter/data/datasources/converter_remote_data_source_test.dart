import 'package:currency_converter/core/network/api_client.dart';
import 'package:currency_converter/features/converter/data/datasources/converter_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late List<Uri> requests;
  late ConverterRemoteDataSourceImpl dataSource;

  setUp(() {
    requests = [];
    dataSource = ConverterRemoteDataSourceImpl(
      ApiClient(
        MockClient((request) async {
          requests.add(request.url);
          return switch (request.url.path) {
            final p when p.endsWith('/currencies') => http.Response(
              '{"USD":"US Dollar","EUR":"Euro"}',
              200,
            ),
            _ => http.Response(
              '{"base":"USD","date":"2026-09-24","rates":{"EUR":0.88}}',
              200,
            ),
          };
        }),
      ),
    );
  });

  test('getCurrencies fetches and parses the currency list', () async {
    final currencies = await dataSource.getCurrencies();

    expect(requests.single.path, endsWith('/currencies'));
    expect(currencies.map((c) => c.code), ['EUR', 'USD']);
  });

  test('getLatestRates requests all rates for the base currency', () async {
    final rates = await dataSource.getLatestRates('USD');

    expect(requests.single.path, endsWith('/latest'));
    expect(requests.single.queryParameters, {'from': 'USD'});
    expect(rates.base, 'USD');
    expect(rates.rates['EUR'], 0.88);
  });
}
