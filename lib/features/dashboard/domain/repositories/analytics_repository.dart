import 'package:shiftiq_mobile_app_flutter/features/dashboard/domain/model/aggregates/branch_summary.dart';

/// Contract interface for analytics and KPIs in Analytics Bounded Context
abstract class AnalyticsRepository {
  Future<BranchSummary> getBranchSummary(String branchId);
}

