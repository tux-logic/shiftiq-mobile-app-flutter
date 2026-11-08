/// Domain Entity representing the authenticated B2B session in ShiftIQ
class UserSession {
  final String id;
  final String username;
  final String token;
  final String refreshToken;
  final List<String> roles;

  const UserSession({
    required this.id,
    required this.username,
    required this.token,
    required this.refreshToken,
    required this.roles,
  });

  bool get isOwner => roles.contains('ROLE_OWNER') || roles.contains('OWNER');
  bool get isBranchManager =>
      roles.contains('ROLE_BRANCH_MANAGER') || roles.contains('BRANCH_MANAGER');
  bool get isEmployee =>
      roles.contains('ROLE_EMPLOYEE') || roles.contains('EMPLOYEE');

  bool get hasWorkshopManagementAccess => isOwner || isBranchManager;
}
