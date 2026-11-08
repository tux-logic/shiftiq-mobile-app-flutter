import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/infrastructure/remote/branch_api.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchApi branchApi;
  final SessionStorage sessionStorage;

  BranchRepositoryImpl({required this.branchApi, required this.sessionStorage});

  @override
  Future<List<Workshop>> getWorkshops() async {
    final dtos = await branchApi.getWorkshops();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<Branch>> getBranchesByWorkshop(String workshopId) async {
    final dtos = await branchApi.getBranches(workshopId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> setActiveBranch(Branch branch) async {
    await sessionStorage.setActiveBranch(
      branchId: branch.id,
      branchName: branch.name,
    );
    await sessionStorage.setActiveWorkshop(branch.workshopId);
  }

  @override
  Future<String?> getActiveBranchId() async {
    return sessionStorage.activeBranchId;
  }

  @override
  Future<String?> getActiveBranchName() async {
    return sessionStorage.activeBranchName;
  }
}
