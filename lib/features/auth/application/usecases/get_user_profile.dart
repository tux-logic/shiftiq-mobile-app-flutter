import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/entities/user_account.dart';

/// Use case orchestrating retrieval of user account profile by ID or email.
class GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCase({required this.repository});

  Future<UserAccount> byId(String userId) {
    return repository.getUserById(userId);
  }

  Future<UserAccount> byEmail(String email) {
    return repository.getUserByEmail(email);
  }
}
