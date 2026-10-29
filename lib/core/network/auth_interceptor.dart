import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends QueuedInterceptor {
  final ISecureStorageService storageService;
  final Dio _refreshDio;

  AuthInterceptor({
    required this.storageService,
    Dio? refreshDio,
  })  : _refreshDio = refreshDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.activeBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip authorization header for public or refresh endpoints
    final isPublic = options.extra['isPublic'] == true ||
        options.path.contains(ApiEndpoints.login) ||
        options.path.contains(ApiEndpoints.refreshToken);

    if (!isPublic) {
      final token = await storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Intercept 401 Unauthorized for token refresh
    final isRefreshCall = err.requestOptions.path.contains(ApiEndpoints.refreshToken);
    final isLoginCall = err.requestOptions.path.contains(ApiEndpoints.login);

    if (err.response?.statusCode == 401 && !isRefreshCall && !isLoginCall) {
      final refreshToken = await storageService.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Single-use token rotation: request new tokens
          final response = await _refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['token'] as String;
            final newRefreshToken = response.data['refreshToken'] as String;

            // Save rotated tokens atomically
            await storageService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry original request with newly acquired access token
            final originalOptions = err.requestOptions;
            originalOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _refreshDio.fetch(originalOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // If refresh token fails/is invalid, clear credentials
          await storageService.clearAll();
        }
      }
    }

    return handler.next(err);
  }
}
