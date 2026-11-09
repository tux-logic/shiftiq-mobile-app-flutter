import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case retrieving historical financial snapshots for a branch over a specified date range.
class GetBranchFinancialAnalyticsUseCase {
  final AnalyticsRepository repository;

  GetBranchFinancialAnalyticsUseCase({
    AnalyticsRepository? repository,
    AnalyticsRepository? analyticsRepository,
  }) : repository = (repository ?? analyticsRepository)!;

  Future<List<FinancialAnalyticsSnapshot>> execute({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getBranchFinancialAnalytics(
      branchId: branchId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<FinancialAnalyticsSnapshot>> call({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      execute(
        branchId: branchId,
        startDate: startDate,
        endDate: endDate,
      );
}
