import 'package:shiftiq_mobile_app_flutter/features/dashboard/domain/branch_summary.dart';

class BranchSummaryDto {
  final String branchId;
  final double totalRevenue;
  final int completedWorkOrdersCount;
  final int totalAppointmentsCount;
  final int lowStockAlertsCount;
  final int dtcAlertsCount;

  BranchSummaryDto({
    required this.branchId,
    required this.totalRevenue,
    required this.completedWorkOrdersCount,
    required this.totalAppointmentsCount,
    required this.lowStockAlertsCount,
    required this.dtcAlertsCount,
  });

  factory BranchSummaryDto.fromJson(Map<String, dynamic> json) {
    return BranchSummaryDto(
      branchId: json['branchId'] as String? ?? '',
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      completedWorkOrdersCount:
          (json['completedWorkOrdersCount'] as num?)?.toInt() ?? 0,
      totalAppointmentsCount:
          (json['totalAppointmentsCount'] as num?)?.toInt() ?? 0,
      lowStockAlertsCount: (json['lowStockAlertsCount'] as num?)?.toInt() ?? 0,
      dtcAlertsCount: (json['dtcAlertsCount'] as num?)?.toInt() ?? 0,
    );
  }

  BranchSummary toDomain() {
    return BranchSummary(
      branchId: branchId,
      totalRevenue: totalRevenue,
      completedWorkOrdersCount: completedWorkOrdersCount,
      totalAppointmentsCount: totalAppointmentsCount,
      lowStockAlertsCount: lowStockAlertsCount,
      dtcAlertsCount: dtcAlertsCount,
    );
  }
}

