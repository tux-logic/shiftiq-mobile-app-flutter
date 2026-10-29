import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dtos/authenticated_user_dto.dart';
import '../dtos/google_login_request_dto.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/refresh_token_request_dto.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthenticatedUserDto> loginWithEmail(LoginRequestDto request);
  Future<AuthenticatedUserDto> loginWithGoogle(GoogleLoginRequestDto request);
  Future<Map<String, dynamic>> refreshToken(RefreshTokenRequestDto request);
  Future<void> logout();
  Future<List<String>> getActiveRoles(String userId);
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource({required this.dio});

  @override
  Future<AuthenticatedUserDto> loginWithEmail(LoginRequestDto request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
        options: Options(extra: {'isPublic': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthenticatedUserDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: 'Error al iniciar sesión',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException(
          message: 'Correo o contraseña incorrectos.',
          code: 'UNAUTHORIZED',
        );
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Error de conexión con el servidor',
        statusCode: e.response?.statusCode,
        code: e.response?.data?['code']?.toString() ?? 'SERVER_ERROR',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Error inesperado al iniciar sesión: $e');
    }
  }

  @override
  Future<AuthenticatedUserDto> loginWithGoogle(GoogleLoginRequestDto request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.googleLogin,
        data: request.toJson(),
        options: Options(extra: {'isPublic': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthenticatedUserDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: 'Error al autenticar con Google',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Error al conectar con Google Sign-In',
        statusCode: e.response?.statusCode,
        code: e.response?.data?['code']?.toString() ?? 'GOOGLE_AUTH_ERROR',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Error inesperado en Google Sign-In: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(RefreshTokenRequestDto request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: request.toJson(),
        options: Options(extra: {'isPublic': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: 'Error al refrescar token',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw const UnauthorizedException(
          message: 'La sesión ha expirado.',
          code: 'REFRESH_TOKEN_EXPIRED',
        );
      }
      throw ServerException(
        message: 'Error al renovar la sesión',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.delete(ApiEndpoints.logout);
    } catch (_) {
      // Ignored: best-effort remote token revocation
    }
  }

  @override
  Future<List<String>> getActiveRoles(String userId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.userProfilesRoles,
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        message: 'No se pudieron consultar los roles del usuario',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
