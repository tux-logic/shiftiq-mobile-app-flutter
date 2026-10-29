import '../domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final IAuthRepository repository;

  const VerifyOtpUseCase({required this.repository});

  Future<void> call({required String email, required String code}) {
    return repository.verifyOtp(email: email, code: code);
  }
}
