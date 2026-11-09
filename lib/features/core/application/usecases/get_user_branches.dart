import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case retrieving and managing physical workshop branches.
class GetUserBranchesUseCase {
  final CoreRepository repository;

  GetUserBranchesUseCase({required this.repository});

  /// Retrieves branches for a specific workshop, or across all accessible workshops if omitted.
  Future<List<Branch>> execute([String? workshopId]) async {
    if (workshopId != null && workshopId.isNotEmpty) {
      return repository.getBranchesByWorkshop(workshopId);
    }

    final workshops = await repository.getWorkshops();
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
    String? phone,
  }) {
    return repository.createBranch(
      workshopId: workshopId,
      code: code,
      name: name,
      address: address,
      phone: phone,
    );
  }

  Future<Branch> updateBranch({
    required String branchId,
    required String code,
    required String name,
    required String address,
    String? phone,
  }) {
    return repository.updateBranch(
      branchId: branchId,
      code: code,
      name: name,
      address: address,
      phone: phone,
    );
  }
}
