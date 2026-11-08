/// Aggregate Root representing daily KPIs for a workshop branch in Analytics Bounded Context
class BranchSummary {
  final String branchId;
  final double totalRevenue;
  final int completedWorkOrdersCount;
  final int totalAppointmentsCount;
  final int lowStockAlertsCount;
  final int dtcAlertsCount;

  const BranchSummary({
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
}
