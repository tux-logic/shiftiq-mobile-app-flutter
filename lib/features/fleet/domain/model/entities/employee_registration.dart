/// Entity representing an employee registration or job application to a physical branch.
class EmployeeRegistration {
  final String id;
  final String employeeId;
  final String branchId;
  final String speciality;
  final String specialityName;
  final double salary;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? approvedAt;

  const EmployeeRegistration({
    required this.id,
    required this.employeeId,
    required this.branchId,
    required this.speciality,
    required this.specialityName,
    required this.salary,
    this.role = 'ROLE_EMPLOYEE',
    required this.status,
    this.createdAt,
    this.approvedAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isPendingApproval => status.toUpperCase() == 'PENDING_APPROVAL';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  EmployeeRegistration copyWith({
    String? id,
    String? employeeId,
    String? branchId,
    String? speciality,
    String? specialityName,
    double? salary,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return EmployeeRegistration(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      branchId: branchId ?? this.branchId,
      speciality: speciality ?? this.speciality,
      specialityName: specialityName ?? this.specialityName,
      salary: salary ?? this.salary,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
