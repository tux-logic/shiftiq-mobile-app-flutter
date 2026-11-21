/// Domain Entity representing an Owner profile in the Core domain.
class OwnerProfile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String documentType;
  final String documentNumber;
  final String phone;

  const OwnerProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
  });

  String get fullName => '$firstName $lastName'.trim();
}

/// Domain Entity representing an Employee profile in the Core domain.
class EmployeeProfile {
  final String employeeId;
  final String workshopId;
  final String firstName;
  final String lastName;
  final String documentType;
  final String documentNumber;
  final String phone;

  const EmployeeProfile({
    required this.employeeId,
    required this.workshopId,
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
  });

  String get fullName => '$firstName $lastName'.trim();
}

/// Domain Entity representing a Customer profile in the Core domain.
class CustomerProfile {
  final String customerId;
  final String userId;
  final bool isCorporate;
  final String firstName;
  final String lastName;
  final String? businessName;
  final String documentType;
  final String documentNumber;
  final String phone;

  const CustomerProfile({
    required this.customerId,
    required this.userId,
    this.isCorporate = false,
    required this.firstName,
    required this.lastName,
    this.businessName,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
  });

  String get displayName =>
      isCorporate && businessName != null && businessName!.isNotEmpty
          ? businessName!
          : '$firstName $lastName'.trim();
}

/// Domain Aggregate representing the complete unified profile context
/// of an authenticated user across all core roles (/api/v1/profiles/me).
class UserProfileContext {
  final String userId;
  final List<String> roles;
  final OwnerProfile? owner;
  final EmployeeProfile? employee;
  final CustomerProfile? customer;

  const UserProfileContext({
    required this.userId,
    this.roles = const [],
    this.owner,
    this.employee,
    this.customer,
  });

  bool get isOwner => owner != null || roles.contains('ROLE_OWNER');
  bool get isEmployee => employee != null || roles.contains('ROLE_EMPLOYEE');
  bool get isCustomer => customer != null || roles.contains('ROLE_CUSTOMER');
}
