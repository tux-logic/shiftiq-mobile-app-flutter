import 'package:shiftiq_mobile_app_flutter/features/branch/domain/model/aggregates/branch.dart';

/// Contract interface for Workshop and Branch management in Workshop Bounded Context
abstract class BranchRepository {
  Future<List<Workshop>> getWorkshops();

  Future<List<Branch>> getBranchesByWorkshop(String workshopId);

  Future<void> setActiveBranch(Branch branch);

  Future<String?> getActiveBranchId();

  Future<String?> getActiveBranchName();
}
