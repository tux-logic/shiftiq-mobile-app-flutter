/// Aggregate root representing the daily executive KPIs for an authorized workshop branch.
class BranchAnalyticsSummary {
  final String branchId;
  final double totalRevenue;
  final int completedWorkOrdersCount;
  final int totalAppointmentsCount;
  final int lowStockAlertsCount;
  final int dtcAlertsCount;

  const BranchAnalyticsSummary({
    required this.branchId,
    required this.totalRevenue,
    required this.completedWorkOrdersCount,
    required this.totalAppointmentsCount,
    required this.lowStockAlertsCount,
    required this.dtcAlertsCount,
  });

  bool get hasCriticalAlerts => lowStockAlertsCount > 0 || dtcAlertsCount > 0;
  int get totalAlertsCount => lowStockAlertsCount + dtcAlertsCount;
  String get formattedRevenue => 'S/ ${totalRevenue.toStringAsFixed(2)}';

  BranchAnalyticsSummary copyWith({
    String? branchId,
    double? totalRevenue,
    int? completedWorkOrdersCount,
    int? totalAppointmentsCount,
    int? lowStockAlertsCount,
    int? dtcAlertsCount,
  }) {
    return BranchAnalyticsSummary(
      branchId: branchId ?? this.branchId,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      completedWorkOrdersCount:
          completedWorkOrdersCount ?? this.completedWorkOrdersCount,
      totalAppointmentsCount:
          totalAppointmentsCount ?? this.totalAppointmentsCount,
      lowStockAlertsCount: lowStockAlertsCount ?? this.lowStockAlertsCount,
      dtcAlertsCount: dtcAlertsCount ?? this.dtcAlertsCount,
    );
  }
}

/// Backward compatibility alias.
typedef BranchSummary = BranchAnalyticsSummary;
