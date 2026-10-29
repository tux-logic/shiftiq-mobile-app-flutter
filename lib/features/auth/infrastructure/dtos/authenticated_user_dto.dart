import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';

class AuthenticatedUserDto {
  final String id;
  final String email;
  final String role;
  final String token;
  final String refreshToken;
  final int accessTokenExpiresInSeconds;

  const AuthenticatedUserDto({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    required this.refreshToken,
    this.accessTokenExpiresInSeconds = 900,
  });

  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUserDto(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'ROLE_USER',
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      accessTokenExpiresInSeconds: json['accessTokenExpiresInSeconds'] as int? ?? 900,
    );
  }

  User toDomainUser() {
    return User(
      id: id,
      email: email,
      role: role,
    );
  }

  AuthTokens toDomainTokens() {
    return AuthTokens(
      accessToken: token,
      refreshToken: refreshToken,
      expiresInSeconds: accessTokenExpiresInSeconds,
    );
  }
}
