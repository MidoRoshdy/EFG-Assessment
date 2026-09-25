import 'dart:async';
import 'dart:io';

import 'package:currency_converter/core/error/exceptions.dart';
import 'package:currency_converter/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  ApiClient clientReturning(Future<http.Response> Function(http.Request) fn) =>
      ApiClient(MockClient(fn));

  test('returns decoded JSON and sends query parameters', () async {
    late Uri requested;
    final client = clientReturning((request) async {
      requested = request.url;
      return http.Response('{"base":"USD"}', 200);
    });

    final json = await client.get('/latest', query: {'from': 'USD'});

    expect(json, {'base': 'USD'});
    expect(requested.path, endsWith('/latest'));
    expect(requested.queryParameters, {'from': 'USD'});
  });

  test('throws ServerException with API message on error status', () {
    final client = clientReturning(
      (_) async => http.Response('{"message":"bad currency pair"}', 422),
    );

    expect(
      () => client.get('/latest'),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'bad currency pair',
        ),
      ),
    );
  });

  test('throws ServerException with status code when no message', () {
    final client = clientReturning((_) async => http.Response('{}', 500));

    expect(
      () => client.get('/latest'),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          contains('500'),
        ),
      ),
    );
  });

  test('throws NetworkException when offline', () {
    final client = clientReturning(
      (_) async => throw const SocketException('offline'),
    );

    expect(() => client.get('/latest'), throwsA(isA<NetworkException>()));
  });

  test('throws NetworkException on timeout', () {
    final client = clientReturning((_) async => throw TimeoutException('slow'));

    expect(() => client.get('/latest'), throwsA(isA<NetworkException>()));
  });

  test('throws ServerException on invalid JSON', () {
    final client = clientReturning(
      (_) async => http.Response('<html>oops</html>', 200),
    );

    expect(() => client.get('/latest'), throwsA(isA<ServerException>()));
  });
}
