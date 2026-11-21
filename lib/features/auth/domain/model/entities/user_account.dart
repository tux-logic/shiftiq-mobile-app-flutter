import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/value_objects/user_role.dart';

/// Entity representing a registered user account in the ShiftIQ IAM Context.
class UserAccount {
  final String id;
  final String email;
  final UserRole role;

  const UserAccount({
    required this.id,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isOwner => role == UserRole.owner;
  bool get isBranchManager => role == UserRole.branchManager;
  bool get isEmployee => role == UserRole.employee;

  @override
  String toString() =>
      'UserAccount(id: $id, email: $email, role: ${role.roleName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAccount &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ role.hashCode;
}
