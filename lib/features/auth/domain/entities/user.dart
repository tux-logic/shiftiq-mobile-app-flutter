import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String role;
  final List<String> branchIds;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.branchIds = const [],
  });

  bool get isCustomer => role == 'ROLE_USER' || role == 'ROLE_CUSTOMER';
  bool get isEmployee => role == 'ROLE_EMPLOYEE' || role == 'ROLE_ASSISTANT' || role == 'ROLE_BRANCH_MANAGER';
  bool get isOwner => role == 'ROLE_OWNER' || role == 'ROLE_ADMIN';

  @override
  List<Object?> get props => [id, email, role, branchIds];
}
