import '../domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final IAuthRepository repository;

  const LogoutUseCase({required this.repository});

  Future<void> call() {
    return repository.logout();
  }
}
