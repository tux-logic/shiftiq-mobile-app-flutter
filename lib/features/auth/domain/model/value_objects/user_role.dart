/// Represents the authorization role hierarchy in the ShiftIQ platform.
enum UserRole {
  admin('ROLE_ADMIN', 4),
  owner('ROLE_OWNER', 3),
  branchManager('ROLE_BRANCH_MANAGER', 2),
  assistant('ROLE_ASSISTANT', 1),
  employee('ROLE_EMPLOYEE', 0),
  user('ROLE_USER', 0),
  customer('ROLE_CUSTOMER', 0);

  final String roleName;
  final int level;

  const UserRole(this.roleName, this.level);

  static UserRole fromString(String value) {
    final clean = value.trim().toUpperCase();
    for (final role in values) {
      if (role.roleName == clean || role.name.toUpperCase() == clean) {
        return role;
      }
    }
    return UserRole.user;
  }
}
