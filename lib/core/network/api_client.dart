import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';

/// Central HTTP Client for ShiftIQ Mobile.
/// Injects Bearer Token, standard headers and maps HTTP error status codes.
class ApiClient {
  final SessionStorage sessionStorage;
  final DomainEventBus? eventBus;
  final http.Client _client;
  Future<bool>? _refreshFuture;

  ApiClient({
    required this.sessionStorage,
    this.eventBus,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _buildHeaders([
    Map<String, String>? extraHeaders,
  ]) async {
    final token = await sessionStorage.getAccessToken();
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.acceptLanguageHeader: appLocaleNotifier.value.languageCode,
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

  bool _canRefreshForPath(String path) {
    return !path.startsWith(ApiConstants.authSessions) &&
        !path.startsWith(ApiConstants.authLogin);
  }

  /// Coordinates concurrent 401 responses into a single `/sessions/refresh` call
  /// so single-use refresh tokens are never rotated twice in parallel.
  Future<bool> _refreshSessionTokens() {
    final inFlight = _refreshFuture;
    if (inFlight != null) return inFlight;

    final future = _performTokenRefresh().whenComplete(() {
      _refreshFuture = null;
    });
    _refreshFuture = future;
    return future;
  }

  Future<bool> _performTokenRefresh() async {
    try {
      final refreshToken = await sessionStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.trim().isEmpty) {
        return false;
      }

      final uri = _buildUri(ApiConstants.authRefresh);
      final response = await _client
          .post(
            uri,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.acceptLanguageHeader:
                  appLocaleNotifier.value.languageCode,
            },
            body: jsonEncode({'refreshToken': refreshToken.trim()}),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final newAccessToken =
          (decoded['token'] ?? decoded['accessToken'])?.toString() ?? '';
      final newRefreshToken = decoded['refreshToken']?.toString() ?? '';
      if (newAccessToken.isEmpty || newRefreshToken.isEmpty) {
        return false;
      }

      await sessionStorage.updateTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> _executeWithRefresh(
    String path,
    Future<http.Response> Function() sendRequest,
  ) async {
    try {
      var response = await sendRequest().timeout(ApiConstants.requestTimeout);
      if (response.statusCode == 401 && _canRefreshForPath(path)) {
        final refreshed = await _refreshSessionTokens();
        if (refreshed) {
          response = await sendRequest().timeout(ApiConstants.requestTimeout);
        }
      }
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(details: e.message);
    } on TimeoutException {
      throw NetworkException(
        message:
            'Tiempo de espera agotado: el servidor en Render está iniciando. Por favor reintenta.',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Connection error: $e');
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    final uri = _buildUri(path, queryParameters);
    return _executeWithRefresh(path, () async {
      final requestHeaders = await _buildHeaders(headers);
      return _client.get(uri, headers: requestHeaders);
    });
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    final uri = _buildUri(path, queryParameters);
    return _executeWithRefresh(path, () async {
      final requestHeaders = await _buildHeaders(headers);
      return _client.post(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    final uri = _buildUri(path, queryParameters);
    return _executeWithRefresh(path, () async {
      final requestHeaders = await _buildHeaders(headers);
      return _client.put(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    final uri = _buildUri(path, queryParameters);
    return _executeWithRefresh(path, () async {
      final requestHeaders = await _buildHeaders(headers);
      return _client.patch(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> delete(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    final uri = _buildUri(path, queryParameters);
    return _executeWithRefresh(path, () async {
      final requestHeaders = await _buildHeaders(headers);
      return _client.delete(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> uploadMultipart(
    String path, {
    required List<int> fileBytes,
    required String fileName,
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    final uri = _buildUri(path, queryParameters);
    return _executeWithRefresh(path, () async {
      final request = http.MultipartRequest('POST', uri);

      final token = await sessionStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
      request.headers[HttpHeaders.acceptHeader] = 'application/json';
      if (headers != null) {
        request.headers.addAll(headers);
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
          contentType: _resolveMediaType(fileName, fileBytes),
        ),
      );

      final streamedResponse = await _client.send(request);
      return http.Response.fromStream(streamedResponse);
    });
  }

  /// Resolves the image MIME type from [fileName] extension or magic bytes
  /// so multipart uploads do not default to `application/octet-stream`.
  MediaType _resolveMediaType(String fileName, List<int> fileBytes) {
    final dotIndex = fileName.lastIndexOf('.');
    final ext = dotIndex != -1
        ? fileName.substring(dotIndex + 1).toLowerCase()
        : '';

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      case 'svg':
        return MediaType('image', 'svg+xml');
      case 'avif':
        return MediaType('image', 'avif');
    }

    if (fileBytes.length >= 4) {
      if (fileBytes[0] == 0xFF && fileBytes[1] == 0xD8 && fileBytes[2] == 0xFF) {
        return MediaType('image', 'jpeg');
      }
      if (fileBytes[0] == 0x89 &&
          fileBytes[1] == 0x50 &&
          fileBytes[2] == 0x4E &&
          fileBytes[3] == 0x47) {
        return MediaType('image', 'png');
      }
      if (fileBytes[0] == 0x47 && fileBytes[1] == 0x49 && fileBytes[2] == 0x46) {
        return MediaType('image', 'gif');
      }
      if (fileBytes.length >= 12 &&
          fileBytes[0] == 0x52 &&
          fileBytes[1] == 0x49 &&
          fileBytes[2] == 0x46 &&
          fileBytes[3] == 0x46 &&
          fileBytes[8] == 0x57 &&
          fileBytes[9] == 0x45 &&
          fileBytes[10] == 0x42 &&
          fileBytes[11] == 0x50) {
        return MediaType('image', 'webp');
      }
    }

    return MediaType('application', 'octet-stream');
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
              'Server error')
        : 'Server error ($statusCode)';

    switch (statusCode) {
      case 400:
        throw ValidationException(
          message: message.toString(),
          details: decodedJson,
        );
      case 401:
        eventBus?.emit(
          SessionExpiredEvent(
            reason: message.toString(),
          ),
        );
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
      case 409:
        throw ConflictException(
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
