import 'package:shiftiq_mobile_app_flutter/features/dashboard/domain/branch_summary.dart';

/// Contract interface for analytics and KPIs
abstract class AnalyticsRepository {
  Future<BranchSummary> getBranchSummary(String branchId);
}

