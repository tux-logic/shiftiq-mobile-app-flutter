import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';

class SessionResponseDto {
  final String id;
  final String username;
  final String token;
  final String refreshToken;
  final List<String> roles;

  SessionResponseDto({
    required this.id,
    required this.username,
    required this.token,
    required this.refreshToken,
    required this.roles,
  });

  factory SessionResponseDto.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    List<String> parsedRoles = [];
    if (rolesRaw is List) {
      parsedRoles = rolesRaw.map((e) => e.toString()).toList();
    } else if (rolesRaw is String) {
      parsedRoles = [rolesRaw];
    }

    return SessionResponseDto(
      id: json['id'] as String? ?? json['userId'] as String? ?? '',
      username: json['username'] as String? ?? json['email'] as String? ?? '',
      token: json['token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      roles: parsedRoles,
    );
  }

  UserSession toDomain() {
    return UserSession(
      id: id,
      username: username,
      token: token,
      refreshToken: refreshToken,
      roles: roles,
    );
  }
}
