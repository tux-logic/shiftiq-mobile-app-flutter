import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';

/// Contract interface defining data retrieval for the Analytics Bounded Context.
abstract class AnalyticsRepository {
  /// Retrieves executive daily operational metrics for an authorized branch.
  Future<BranchAnalyticsSummary> getBranchSummary(String branchId);

  /// Retrieves chronological daily financial snapshots within an optional date window.
  /// If [startDate] is null, defaults to 30 days prior. If [endDate] is null, defaults to today.
  Future<List<FinancialAnalyticsSnapshot>> getBranchFinancialAnalytics({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Retrieves consolidated multi-branch network analytics for platform owners and administrators.
  Future<NetworkAnalyticsSummary> getNetworkSummary();
}
