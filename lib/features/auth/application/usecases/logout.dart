import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';

/// Use case orchestrating server-side session revocation and local state purge.
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  Future<void> execute() {
    return repository.logout();
  }
}
