import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case orchestrating hierarchical staff onboarding to a physical branch.
class OnboardEmployeeUseCase {
  final FleetRepository repository;

  OnboardEmployeeUseCase({required this.repository});

  Future<EmployeeRegistration> execute({
    required String employeeId,
    required String branchId,
    required String speciality,
    required String specialityName,
    required double salary,
    String role = 'ROLE_EMPLOYEE',
  }) {
    return repository.onboardEmployee(
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
      role: role,
    );
  }
}
