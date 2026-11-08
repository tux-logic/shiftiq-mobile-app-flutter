import 'package:shiftiq_mobile_app_flutter/features/dashboard/domain/analytics_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/domain/branch_summary.dart';

class GetBranchSummaryUseCase {
  final AnalyticsRepository repository;

  GetBranchSummaryUseCase({required this.repository});

  Future<BranchSummary> execute(String branchId) {
    return repository.getBranchSummary(branchId);
  }
}

