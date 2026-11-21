import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';

/// Use case retrieving and managing physical workshop branches.
class GetUserBranchesUseCase {
  final CoreRepository repository;
  final EmployeeRegistrationApi? employeeRegistrationApi;

  GetUserBranchesUseCase({
    required this.repository,
    this.employeeRegistrationApi,
  });

  /// Retrieves branches for a specific workshop, or across all accessible workshops for an owner or employee.
  Future<List<Branch>> execute({String? workshopId, String? ownerId}) async {
    if (workshopId != null && workshopId.isNotEmpty) {
      try {
        final branches = await repository.getBranchesByWorkshop(workshopId);
        if (branches.isNotEmpty) return branches;
      } catch (_) {}
    }

    try {
      final profile = await repository.getMyProfileContext();

      // Case 1: Owner profile
      if (profile.owner != null) {
        final workshops = await repository.getWorkshops(ownerId: profile.owner!.id);
        final allBranches = <Branch>[];
        for (final workshop in workshops) {
          final branches = await repository.getBranchesByWorkshop(workshop.id);
          allBranches.addAll(branches);
        }
        if (allBranches.isNotEmpty) return allBranches;
      }

      // Case 2: Employee profile (Mechanic / Assistant / Manager)
      if (profile.employee != null &&
          profile.employee!.workshopId.isNotEmpty) {
        final branches = await repository.getBranchesByWorkshop(
          profile.employee!.workshopId,
        );
        if (branches.isNotEmpty) return branches;
      }
    } catch (_) {}

    // Fallback attempt via repository workshops
    final workshops = await repository.getWorkshops(ownerId: ownerId);
    final allBranches = <Branch>[];
    for (final workshop in workshops) {
      final branches = await repository.getBranchesByWorkshop(workshop.id);
      allBranches.addAll(branches);
    }
    return allBranches;
  }

  Future<Branch> getBranchById(String branchId) {
    return repository.getBranchById(branchId);
  }

  Future<Branch> createBranch({
    required String workshopId,
    required String code,
    required String name,
    required String address,
    required String phone,
    String? coverImageUrl,
    double? latitude,
    double? longitude,
  }) {
    return repository.createBranch(
      workshopId: workshopId,
      code: code,
      name: name,
      address: address,
      phone: phone,
      coverImageUrl: coverImageUrl,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<Branch> updateBranch({
    required String branchId,
    required String code,
    required String name,
    required String address,
    required String phone,
    String? coverImageUrl,
    double? latitude,
    double? longitude,
  }) {
    return repository.updateBranch(
      branchId: branchId,
      code: code,
      name: name,
      address: address,
      phone: phone,
      coverImageUrl: coverImageUrl,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
