import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';

/// Central HTTP Client for ShiftIQ Mobile
/// Injects Bearer Token, standard headers and maps HTTP error status codes
class ApiClient {
  final SessionStorage sessionStorage;
  final http.Client _client;

  ApiClient({required this.sessionStorage, http.Client? client})
    : _client = client ?? http.Client();

  Future<Map<String, String>> _buildHeaders([
    Map<String, String>? extraHeaders,
  ]) async {
    final token = await sessionStorage.getAccessToken();
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final urlString = '${ApiConstants.baseUrl}$cleanPath';
    final baseUri = Uri.parse(urlString);

    if (queryParameters == null || queryParameters.isEmpty) {
      return baseUri;
    }

    final queryMap = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        queryMap[key] = value.toString();
      }
    });

    return baseUri.replace(queryParameters: queryMap);
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final requestHeaders = await _buildHeaders(headers);
      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(ApiConstants.requestTimeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(details: e.message);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Error de conexión: $e');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final requestHeaders = await _buildHeaders(headers);
      final response = await _client
          .post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.requestTimeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(details: e.message);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Error de conexión: $e');
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final requestHeaders = await _buildHeaders(headers);
      final response = await _client
          .put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.requestTimeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(details: e.message);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Error de conexión: $e');
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final requestHeaders = await _buildHeaders(headers);
      final response = await _client
          .patch(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.requestTimeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(details: e.message);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Error de conexión: $e');
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final requestHeaders = await _buildHeaders(headers);
      final response = await _client
          .delete(uri, headers: requestHeaders)
          .timeout(ApiConstants.requestTimeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(details: e.message);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Error de conexión: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = utf8.decode(response.bodyBytes);

    dynamic decodedJson;
    if (bodyString.isNotEmpty) {
      try {
        decodedJson = jsonDecode(bodyString);
      } catch (_) {
        decodedJson = bodyString;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedJson;
    }

    final message = decodedJson is Map<String, dynamic>
        ? (decodedJson['message'] ??
              decodedJson['error'] ??
              'Error del servidor')
        : 'Error del servidor ($statusCode)';

    switch (statusCode) {
      case 400:
        throw ValidationException(
          message: message.toString(),
          details: decodedJson,
        );
      case 401:
        throw AuthenticationException(
          message: message.toString(),
          details: decodedJson,
        );
      case 403:
        throw AccessDeniedException(
          message: message.toString(),
          details: decodedJson,
        );
      case 404:
        throw NotFoundException(
          message: message.toString(),
          details: decodedJson,
        );
      case 500:
      default:
        throw ServerException(
          message: message.toString(),
          statusCode: statusCode,
          details: decodedJson,
        );
    }
  }
}
