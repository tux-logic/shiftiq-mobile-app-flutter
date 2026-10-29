import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresInSeconds = 900,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresInSeconds];
}
