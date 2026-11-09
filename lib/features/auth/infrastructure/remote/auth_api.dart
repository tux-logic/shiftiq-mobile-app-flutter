import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/auth_dto.dart';

/// Remote HTTP client for IAM authentication endpoints (`/api/v1/authentication`).
class AuthApi {
  final ApiClient apiClient;

  AuthApi({required this.apiClient});

  /// Authenticates using email and password.
  Future<AuthenticatedUserDto> signIn({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.authSessions,
      body: {'email': email.trim(), 'password': password},
    );

    return AuthenticatedUserDto.fromJson(response as Map<String, dynamic>);
  }

  /// Authenticates or registers via Google OAuth ID Token.
  Future<AuthenticatedUserDto> signInWithGoogle({
    required String idToken,
  }) async {
    final response = await apiClient.post(
      ApiConstants.authGoogle,
      body: {'idToken': idToken.trim()},
    );

    return AuthenticatedUserDto.fromJson(response as Map<String, dynamic>);
  }

  /// Rotates single-use refresh token for new access and refresh tokens.
  Future<AuthenticatedUserDto> refreshToken({
    required String refreshToken,
  }) async {
    final response = await apiClient.post(
      ApiConstants.authRefresh,
      body: {'refreshToken': refreshToken.trim()},
    );

    return AuthenticatedUserDto.fromJson(response as Map<String, dynamic>);
  }

  /// Revokes active session refresh token on the server.
  Future<void> logout({
    required String refreshToken,
  }) async {
    await apiClient.delete(
      ApiConstants.authSessions,
      body: {'refreshToken': refreshToken.trim()},
    );
  }

  /// Sends password recovery email with single-use token.
  Future<void> requestPasswordRecovery({
    required String email,
  }) async {
    await apiClient.post(
      ApiConstants.passwordRecoveries,
      body: {'email': email.trim()},
    );
  }

  /// Resets user password using the single-use recovery token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await apiClient.post(
      ApiConstants.passwordResets,
      body: {
        'token': token.trim(),
        'newPassword': newPassword,
      },
    );
  }

  /// Sends a 6-digit verification OTP code to the target email.
  Future<void> sendOtp({
    required String email,
  }) async {
    await apiClient.post(
      ApiConstants.otpSend,
      body: {'email': email.trim()},
    );
  }

  /// Verifies the 6-digit OTP code against the server record.
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    await apiClient.post(
      ApiConstants.otpVerify,
      body: {
        'email': email.trim(),
        'code': code.trim(),
      },
    );
  }
}
