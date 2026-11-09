import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';

/// Use case orchestrating 6-digit OTP code dispatch to target email.
class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase({required this.repository});

  Future<void> execute({required String email}) {
    return repository.sendOtp(email: email);
  }
}

/// Use case orchestrating 6-digit OTP code verification.
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase({required this.repository});

  Future<void> execute({
    required String email,
    required String code,
  }) {
    return repository.verifyOtp(email: email, code: code);
  }
}
