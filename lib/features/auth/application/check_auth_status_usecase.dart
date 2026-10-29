import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final IAuthRepository repository;

  const CheckAuthStatusUseCase({required this.repository});

  Future<User?> call() {
    return repository.getCurrentUser();
  }
}
