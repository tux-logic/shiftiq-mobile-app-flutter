import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/auth_dto.dart';

/// Remote HTTP client for IAM user management endpoints (`/api/v1/users`).
class UserApi {
  final ApiClient apiClient;

  UserApi({required this.apiClient});

  /// Registers a new user account (requires prior OTP verification).
  Future<UserAccountDto> signUp({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.users,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    return UserAccountDto.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves user account details by ID.
  Future<UserAccountDto> getUserById(String userId) async {
    final response = await apiClient.get(
      ApiConstants.userById(userId),
    );

    return UserAccountDto.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves user account details by exact email.
  Future<UserAccountDto> getUserByEmail(String email) async {
    final response = await apiClient.get(
      ApiConstants.users,
      queryParameters: {'email': email.trim()},
    );

    return UserAccountDto.fromJson(response as Map<String, dynamic>);
  }

  /// Updates account email and returns new session tokens.
  Future<AuthenticatedUserDto> updateUserEmail({
    required String userId,
    required String email,
  }) async {
    final response = await apiClient.put(
      ApiConstants.userEmail(userId),
      body: {'email': email.trim()},
    );

    return AuthenticatedUserDto.fromJson(response as Map<String, dynamic>);
  }

  /// Updates account password after validating current password.
  Future<void> updateUserPassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.put(
      ApiConstants.userPassword(userId),
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
