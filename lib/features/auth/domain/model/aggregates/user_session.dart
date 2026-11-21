/// Aggregate Root representing an authenticated session in the ShiftIQ
/// IAM Bounded Context.
class UserSession {
  final String id;
  final String username;
  final String token;
  final String refreshToken;
  final List<String> roles;
  final int accessTokenExpiresInSeconds;

  const UserSession({
    required this.id,
    required this.username,
    required this.token,
    required this.refreshToken,
    required this.roles,
    this.accessTokenExpiresInSeconds = 900,
  });

  String get email => username;

  bool get isOwner =>
      roles.contains('ROLE_OWNER') || roles.contains('OWNER');

  bool get isBranchManager =>
      roles.contains('ROLE_BRANCH_MANAGER') ||
      roles.contains('BRANCH_MANAGER');

  bool get isEmployee =>
      roles.contains('ROLE_EMPLOYEE') || roles.contains('EMPLOYEE');

  bool get hasWorkshopManagementAccess => isOwner || isBranchManager;

  UserSession copyWith({
    String? id,
    String? username,
    String? token,
    String? refreshToken,
    List<String>? roles,
    int? accessTokenExpiresInSeconds,
  }) {
    return UserSession(
      id: id ?? this.id,
      username: username ?? this.username,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      roles: roles ?? this.roles,
      accessTokenExpiresInSeconds:
          accessTokenExpiresInSeconds ?? this.accessTokenExpiresInSeconds,
    );
  }

  @override
  String toString() =>
      'UserSession(id: $id, email: $username, roles: $roles)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          token == other.token &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode => id.hashCode ^ token.hashCode ^ refreshToken.hashCode;
}
