/// Entity representing a single business day's recorded financial and operational snapshot.
class FinancialAnalyticsSnapshot {
  final String id;
  final String branchId;
  final DateTime snapshotDate;
  final double totalRevenue;
  final int completedWorkOrdersCount;
  final int totalAppointmentsCount;
  final int lowStockAlertsCount;
  final int dtcAlertsCount;

  const FinancialAnalyticsSnapshot({
    required this.id,
    required this.branchId,
    required this.snapshotDate,
    required this.totalRevenue,
    required this.completedWorkOrdersCount,
    required this.totalAppointmentsCount,
    required this.lowStockAlertsCount,
    required this.dtcAlertsCount,
  });

  String get formattedRevenue => 'S/ ${totalRevenue.toStringAsFixed(2)}';

  String get formattedDate =>
      '${snapshotDate.year.toString().padLeft(4, '0')}-${snapshotDate.month.toString().padLeft(2, '0')}-${snapshotDate.day.toString().padLeft(2, '0')}';

  FinancialAnalyticsSnapshot copyWith({
    String? id,
    String? branchId,
    DateTime? snapshotDate,
    double? totalRevenue,
    int? completedWorkOrdersCount,
    int? totalAppointmentsCount,
    int? lowStockAlertsCount,
    int? dtcAlertsCount,
  }) {
    return FinancialAnalyticsSnapshot(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      snapshotDate: snapshotDate ?? this.snapshotDate,
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
