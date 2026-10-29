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
  Future<AuthenticatedUserDto> refreshToken(RefreshTokenRequestDto request);
  Future<void> logout({required String refreshToken});
  Future<void> sendOtp(String email);
  Future<void> verifyOtp(String email, String code);
  Future<Map<String, dynamic>> signUp(String email, String password);
  Future<void> requestPasswordRecovery(String email);
  Future<void> resetPassword(String token, String newPassword);
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
  Future<AuthenticatedUserDto> refreshToken(RefreshTokenRequestDto request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: request.toJson(),
        options: Options(extra: {'isPublic': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthenticatedUserDto.fromJson(response.data as Map<String, dynamic>);
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
  Future<void> sendOtp(String email) async {
    try {
      await dio.post(
        ApiEndpoints.otpSend,
        data: {'email': email},
        options: Options(extra: {'isPublic': true}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AppException(
          message: 'Límite de códigos excedido. Intenta más tarde.',
          code: 'RATE_LIMITED',
        );
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Error al enviar código de verificación.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> verifyOtp(String email, String code) async {
    try {
      await dio.post(
        ApiEndpoints.otpVerify,
        data: {'email': email, 'code': code},
        options: Options(extra: {'isPublic': true}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AppException(
          message: 'Código incorrecto o expirado.',
          code: 'INVALID_OTP',
        );
      }
      if (e.response?.statusCode == 404) {
        throw const AppException(
          message: 'No hay código pendiente para este correo.',
          code: 'NOT_FOUND',
        );
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Error al verificar código.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.users,
        data: {'email': email, 'password': password},
        options: Options(extra: {'isPublic': true}),
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw ServerException(message: 'Error al registrar usuario', statusCode: response.statusCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data?['message']?.toString() ?? '';
        if (message.contains('alreadyInUse')) {
          throw const AppException(
            message: 'Este correo electrónico ya está registrado.',
            code: 'EMAIL_ALREADY_IN_USE',
          );
        }
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Error al crear la cuenta.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> requestPasswordRecovery(String email) async {
    try {
      await dio.post(
        ApiEndpoints.passwordRecoveries,
        data: {'email': email},
        options: Options(extra: {'isPublic': true}),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Error al solicitar recuperación.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await dio.post(
        ApiEndpoints.passwordResets,
        data: {'token': token, 'newPassword': newPassword},
        options: Options(extra: {'isPublic': true}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AppException(
          message: 'Token de recuperación inválido o expirado.',
          code: 'INVALID_RESET_TOKEN',
        );
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Error al restablecer la contraseña.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await dio.delete(
        ApiEndpoints.logout,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'isPublic': true}),
      );
    } catch (_) {
      // Best-effort remote revocation
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
