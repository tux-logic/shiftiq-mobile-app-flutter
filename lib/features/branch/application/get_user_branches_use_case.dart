import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch_repository.dart';

class GetUserBranchesUseCase {
  final BranchRepository repository;

  GetUserBranchesUseCase({required this.repository});

  Future<List<Branch>> execute() async {
    final workshops = await repository.getWorkshops();
    final allBranches = <Branch>[];

    for (final workshop in workshops) {
      final branches = await repository.getBranchesByWorkshop(workshop.id);
      allBranches.addAll(branches);
    }

    return allBranches;
  }
}
