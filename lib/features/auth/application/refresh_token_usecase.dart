import '../domain/entities/auth_tokens.dart';
import '../domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final IAuthRepository repository;

  const RefreshTokenUseCase({required this.repository});

  Future<AuthTokens> call() {
    return repository.refreshToken();
  }
}
