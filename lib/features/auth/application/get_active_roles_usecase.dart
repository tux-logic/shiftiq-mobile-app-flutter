import '../domain/entities/user_profile_role.dart';
import '../domain/repositories/auth_repository.dart';

class GetActiveRolesUseCase {
  final IAuthRepository repository;

  const GetActiveRolesUseCase({required this.repository});

  Future<UserProfileRole> call(String userId) async {
    final roleStrings = await repository.getActiveRoles(userId);
    final roles = roleStrings.map(UserRoleType.fromString).toList();
    return UserProfileRole(roles: roles);
  }
}
