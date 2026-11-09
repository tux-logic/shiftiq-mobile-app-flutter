import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/aggregates/user_session.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/entities/user_account.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/value_objects/user_role.dart';

/// Wire DTO for authenticated user sessions (`AuthenticatedUserResource`).
/// Maps response from `/sessions`, `/sessions/google`, `/sessions/refresh`,
/// and `/users/{userId}/email`.
class AuthenticatedUserDto {
  final String id;
  final String email;
  final List<String> roles;
  final String token;
  final String refreshToken;
  final int accessTokenExpiresInSeconds;

  const AuthenticatedUserDto({
    required this.id,
    required this.email,
    required this.roles,
    required this.token,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
  });

  /// Deserializes JSON using Dart 3 pattern matching and fast-fail validation.
  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': final String id,
      'token': final String token,
      'refreshToken': final String refreshToken,
    }) {
      final email =
          json['email'] as String? ?? json['username'] as String? ?? '';
      final expiresIn = json['accessTokenExpiresInSeconds'] as int? ?? 900;
      final roleRaw = json['role'] ?? json['roles'];

      final roles = switch (roleRaw) {
        final List<dynamic> list => list.map((e) => e.toString()).toList(),
        final String singleRole => [singleRole],
        _ => <String>['ROLE_USER'],
      };

      return AuthenticatedUserDto(
        id: id,
        email: email,
        roles: roles,
        token: token,
        refreshToken: refreshToken,
        accessTokenExpiresInSeconds: expiresIn,
      );
    }

    throw ValidationException(
      message: 'Malformed authenticated user payload',
      details: json,
    );
  }

  UserSession toDomain() {
    return UserSession(
      id: id,
      username: email,
      token: token,
      refreshToken: refreshToken,
      roles: roles,
      accessTokenExpiresInSeconds: accessTokenExpiresInSeconds,
    );
  }
}

/// Backward compatibility alias for legacy codebase.
typedef SessionResponseDto = AuthenticatedUserDto;

/// Wire DTO for user account details (`UserResource`).
/// Maps response from `/users`, `/users/{userId}`, and `/users?email=`.
class UserAccountDto {
  final String id;
  final String email;
  final String role;

  const UserAccountDto({
    required this.id,
    required this.email,
    required this.role,
  });

  factory UserAccountDto.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': final String id,
      'email': final String email,
      'role': final String role,
    }) {
      return UserAccountDto(
        id: id,
        email: email,
        role: role,
      );
    }

    throw ValidationException(
      message: 'Malformed user account payload',
      details: json,
    );
  }

  UserAccount toDomain() {
    return UserAccount(
      id: id,
      email: email,
      role: UserRole.fromString(role),
    );
  }
}
