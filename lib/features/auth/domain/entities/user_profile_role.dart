import 'package:equatable/equatable.dart';

enum UserRoleType {
  admin,
  owner,
  branchManager,
  assistant,
  employee,
  customer,
  unknown;

  static UserRoleType fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ROLE_ADMIN':
      case 'ADMIN':
        return UserRoleType.admin;
      case 'ROLE_OWNER':
      case 'OWNER':
        return UserRoleType.owner;
      case 'ROLE_BRANCH_MANAGER':
      case 'BRANCH_MANAGER':
        return UserRoleType.branchManager;
      case 'ROLE_ASSISTANT':
      case 'ASSISTANT':
        return UserRoleType.assistant;
      case 'ROLE_EMPLOYEE':
      case 'EMPLOYEE':
        return UserRoleType.employee;
      case 'ROLE_USER':
      case 'ROLE_CUSTOMER':
      case 'CUSTOMER':
        return UserRoleType.customer;
      default:
        return UserRoleType.unknown;
    }
  }

  bool get isCustomer => this == UserRoleType.customer;
  bool get isWorkshopEmployee =>
      this == UserRoleType.employee ||
      this == UserRoleType.assistant ||
      this == UserRoleType.branchManager;
  bool get isOwner => this == UserRoleType.owner || this == UserRoleType.admin;
}

class UserProfileRole extends Equatable {
  final List<UserRoleType> roles;

  const UserProfileRole({required this.roles});

  bool get hasCustomerAccess => roles.any((r) => r.isCustomer);
  bool get hasEmployeeAccess => roles.any((r) => r.isWorkshopEmployee);
  bool get hasOwnerAccess => roles.any((r) => r.isOwner);

  @override
  List<Object?> get props => [roles];
}
