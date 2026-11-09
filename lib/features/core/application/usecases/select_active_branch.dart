import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case setting and querying the currently active workshop branch context.
class SelectActiveBranchUseCase {
  final CoreRepository repository;

  SelectActiveBranchUseCase({required this.repository});

  Future<void> execute(Branch branch) {
    return repository.setActiveBranch(branch);
  }

  Future<String?> getActiveBranchId() {
    return repository.getActiveBranchId();
  }

  Future<String?> getActiveBranchName() {
    return repository.getActiveBranchName();
  }
}
