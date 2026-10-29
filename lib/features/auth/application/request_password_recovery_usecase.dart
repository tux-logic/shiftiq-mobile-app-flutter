import '../domain/repositories/auth_repository.dart';

class RequestPasswordRecoveryUseCase {
  final IAuthRepository repository;

  const RequestPasswordRecoveryUseCase({required this.repository});

  Future<void> call({required String email}) {
    return repository.requestPasswordRecovery(email: email);
  }
}
