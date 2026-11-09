import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case retrieving the complete unified profile context for the authenticated caller.
class GetUserProfileContextUseCase {
  final CoreRepository repository;

  GetUserProfileContextUseCase({required this.repository});

  Future<UserProfileContext> execute() {
    return repository.getMyProfileContext();
  }

  Future<List<String>> getRoles(String userId) {
    return repository.getProfileRoles(userId);
  }
}
