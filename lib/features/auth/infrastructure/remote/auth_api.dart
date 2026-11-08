import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/auth_dto.dart';

class AuthApi {
  final ApiClient apiClient;

  AuthApi({required this.apiClient});

  Future<SessionResponseDto> signIn({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.authSessions,
      body: {'email': email.trim(), 'password': password},
    );

    return SessionResponseDto.fromJson(response as Map<String, dynamic>);
  }

  Future<SessionResponseDto> refreshToken({
    required String refreshToken,
  }) async {
    final response = await apiClient.post(
      ApiConstants.authRefresh,
      body: {'refreshToken': refreshToken},
    );

    return SessionResponseDto.fromJson(response as Map<String, dynamic>);
  }

  Future<void> sendPasswordRecoveryOtp(String email) async {
    await apiClient.post(
      ApiConstants.passwordRecoveries,
      body: {'email': email.trim()},
    );
  }
}
