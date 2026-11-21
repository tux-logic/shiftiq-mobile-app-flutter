import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case retrieving the daily executive operational metrics for a workshop branch.
class GetBranchSummaryUseCase {
  final AnalyticsRepository repository;

  GetBranchSummaryUseCase({
    AnalyticsRepository? repository,
    AnalyticsRepository? analyticsRepository,
  }) : repository = (repository ?? analyticsRepository)!;

  Future<BranchAnalyticsSummary> execute(String branchId) {
    return repository.getBranchSummary(branchId);
  }

  Future<BranchAnalyticsSummary> call(String branchId) => execute(branchId);
}

/// Backward compatibility alias.
typedef GetBranchSummary = GetBranchSummaryUseCase;
