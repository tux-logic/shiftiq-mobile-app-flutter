import '../domain/repositories/auth_repository.dart';

class SendOtpUseCase {
  final IAuthRepository repository;

  const SendOtpUseCase({required this.repository});

  Future<void> call({required String email}) {
    return repository.sendOtp(email: email);
  }
}
