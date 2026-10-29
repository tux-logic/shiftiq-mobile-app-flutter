import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient({
    required ISecureStorageService storageService,
    String? baseUrl,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.activeBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(storageService: storageService),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    ]);
  }
}
