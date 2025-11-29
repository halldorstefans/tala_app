import 'dart:convert';
import 'dart:io';

import 'package:tala_app/data/services/tala_api/api_config.dart';

import '../../../utils/result.dart';
import 'package:tala_app/data/models/login_request.dart';
import 'package:tala_app/data/models/login_response.dart';
import 'package:tala_app/data/models/register_request.dart';

class AuthApiClient {
  AuthApiClient({String? baseUrl, HttpClient Function()? httpClient})
    : _baseUrl = baseUrl ?? ApiConfig.baseUrl,
      _httpClient = httpClient ?? HttpClient.new;

  final String _baseUrl;
  final HttpClient Function() _httpClient;

  Future<Result<LoginResponse>> login(LoginRequest loginRequest) async {
    final client = _httpClient();
    try {
      final request = await client.postUrl(Uri.parse('$_baseUrl/login'));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode(loginRequest));
      final response = await request.close();

      if (response.statusCode != 200) {
        return Result.error(HttpException(response.reasonPhrase));
      }

      final responseBody = await response.transform(utf8.decoder).join();
      return Result.ok(LoginResponse.fromJson(jsonDecode(responseBody)));
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<LoginResponse>> register(
    RegisterRequest registerRequest,
  ) async {
    final client = _httpClient();
    try {
      final request = await client.postUrl(Uri.parse('$_baseUrl/register'));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      request.write(jsonEncode(registerRequest));
      final response = await request.close();

      if (response.statusCode != 201) {
        return const Result.error(HttpException('Failed to register'));
      }

      final responseBody = await response.transform(utf8.decoder).join();
      return Result.ok(LoginResponse.fromJson(jsonDecode(responseBody)));
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
