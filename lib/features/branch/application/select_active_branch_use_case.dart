import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch_repository.dart';

class SelectActiveBranchUseCase {
  final BranchRepository repository;

  SelectActiveBranchUseCase({required this.repository});

  Future<void> execute(Branch branch) {
    return repository.setActiveBranch(branch);
  }
}
