import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:currency_converter/core/constants/api_constants.dart';
import 'package:currency_converter/core/error/exceptions.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient(this._client);

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}$path',
    ).replace(queryParameters: query);

    try {
      final response = await _client.get(uri).timeout(ApiConstants.timeout);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }
      throw ServerException(
        body['message'] as String? ?? 'Request failed (${response.statusCode})',
      );
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Request timed out');
    } on FormatException {
      throw const ServerException('Invalid response from server');
    }
  }
}
