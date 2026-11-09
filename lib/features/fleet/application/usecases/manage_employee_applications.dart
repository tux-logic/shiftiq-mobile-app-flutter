import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case managing mechanic applications, manager approvals, and application rejections.
class ManageEmployeeApplicationsUseCase {
  final FleetRepository repository;

  ManageEmployeeApplicationsUseCase({required this.repository});

  /// Mechanic applies to join branch with requested specialty and salary.
  Future<EmployeeRegistration> requestJoin({
    required String employeeId,
    required String branchId,
    String? speciality,
    String? specialityName,
    double? salary,
  }) {
    return repository.requestJoinBranch(
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
    );
  }

  /// Manager approves pending mechanic application (status -> ACTIVE).
  Future<EmployeeRegistration> approve(String registrationId) {
    return repository.approveEmployeeRegistration(registrationId);
  }

  /// Manager rejects pending mechanic application (status -> REJECTED).
  Future<void> reject(String registrationId) {
    return repository.rejectEmployeeRegistration(registrationId);
  }

  /// Lists registrations filtered by branch, status (e.g. PENDING_APPROVAL), or employee.
  Future<List<EmployeeRegistration>> list({
    String? branchId,
    String? status,
    String? employeeId,
  }) {
    return repository.getEmployeeRegistrations(
      branchId: branchId,
      status: status,
      employeeId: employeeId,
    );
  }
}
