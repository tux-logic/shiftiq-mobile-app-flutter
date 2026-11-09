import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Application use case managing staff affiliation contracts, detail lookups, dismissals, and career history.
class ManageStaffAffiliations {
  final FleetRepository repository;

  ManageStaffAffiliations({required this.repository});

  /// Retrieves a specific employee registration by ID.
  Future<EmployeeRegistration> getRegistrationById(String registrationId) {
    final trimmedId = registrationId.trim();
    if (trimmedId.isEmpty) {
      throw ValidationException(message: 'Registration ID cannot be empty');
    }
    return repository.getEmployeeRegistrationById(trimmedId);
  }

  /// Updates contract terms (assigned specialty and/or base monthly salary).
  Future<EmployeeRegistration> updateContractTerms({
    required String registrationId,
    String? speciality,
    String? specialityName,
    double? salary,
  }) {
    final trimmedId = registrationId.trim();
    if (trimmedId.isEmpty) {
      throw ValidationException(message: 'Registration ID cannot be empty');
    }

    if (salary != null && salary < 0) {
      throw ValidationException(message: 'Salary cannot be negative');
    }

    return repository.updateEmployeeRegistration(
      registrationId: trimmedId,
      speciality: speciality?.trim(),
      specialityName: specialityName?.trim(),
      salary: salary,
    );
  }

  /// Dismisses / deactivates staff affiliation from branch.
  Future<void> dismissStaffMember(String registrationId) {
    final trimmedId = registrationId.trim();
    if (trimmedId.isEmpty) {
      throw ValidationException(message: 'Registration ID cannot be empty');
    }
    return repository.deleteEmployeeRegistration(trimmedId);
  }

  /// Retrieves chronological career events for a staff member at a specific branch.
  Future<List<Map<String, dynamic>>> getCareerHistory({
    required String branchId,
    required String employeeId,
  }) {
    final trimmedBranchId = branchId.trim();
    final trimmedEmployeeId = employeeId.trim();

    if (trimmedBranchId.isEmpty) {
      throw ValidationException(message: 'Branch ID cannot be empty');
    }
    if (trimmedEmployeeId.isEmpty) {
      throw ValidationException(message: 'Employee ID cannot be empty');
    }

    return repository.getEmployeeCareerHistory(
      branchId: trimmedBranchId,
      employeeId: trimmedEmployeeId,
    );
  }
}
