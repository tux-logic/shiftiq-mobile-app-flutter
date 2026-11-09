import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';

/// Use case orchestrating account email update and token rotation.
class UpdateUserEmailUseCase {
  final AuthRepository repository;

  UpdateUserEmailUseCase({required this.repository});

  Future<UserSession> execute({
    required String userId,
    required String newEmail,
  }) {
    return repository.updateUserEmail(userId: userId, newEmail: newEmail);
  }
}

/// Use case orchestrating user password update and global session invalidation.
class UpdateUserPasswordUseCase {
  final AuthRepository repository;

  UpdateUserPasswordUseCase({required this.repository});

  Future<void> execute({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    return repository.updateUserPassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
