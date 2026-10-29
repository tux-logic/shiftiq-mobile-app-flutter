import '../domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final IAuthRepository repository;

  const ResetPasswordUseCase({required this.repository});

  Future<void> call({required String token, required String newPassword}) {
    return repository.resetPassword(token: token, newPassword: newPassword);
  }
}
