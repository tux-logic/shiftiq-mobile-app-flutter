import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';

/// Serialization and deserialization utilities for Analytics Bounded Context data transfer objects.
class AnalyticsDto {
  AnalyticsDto._();

  /// Deserializes daily branch analytics summary using Dart 3 pattern matching.
  static BranchAnalyticsSummary branchSummaryFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'branchId': final String branchId,
      } =>
        BranchAnalyticsSummary(
          branchId: branchId,
          totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
          completedWorkOrdersCount:
              (json['completedWorkOrdersCount'] as num?)?.toInt() ?? 0,
          totalAppointmentsCount:
              (json['totalAppointmentsCount'] as num?)?.toInt() ?? 0,
          lowStockAlertsCount:
              (json['lowStockAlertsCount'] as num?)?.toInt() ?? 0,
          dtcAlertsCount: (json['dtcAlertsCount'] as num?)?.toInt() ?? 0,
        ),
      _ => throw FormatException(
          'Invalid BranchAnalyticsSummary payload: missing branchId',
        ),
    };
  }

  /// Deserializes a single financial analytics snapshot item using Dart 3 pattern matching.
  static FinancialAnalyticsSnapshot financialSnapshotFromJson(
    Map<String, dynamic> json,
  ) {
    return switch (json) {
      {
        'branchId': final String branchId,
        'snapshotDate': final String dateStr,
      } =>
        FinancialAnalyticsSnapshot(
          id: json['id'] as String? ?? '',
          branchId: branchId,
          snapshotDate: DateTime.tryParse(dateStr) ?? DateTime.now(),
          totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
          completedWorkOrdersCount:
              (json['completedWorkOrdersCount'] as num?)?.toInt() ?? 0,
          totalAppointmentsCount:
              (json['totalAppointmentsCount'] as num?)?.toInt() ?? 0,
          lowStockAlertsCount:
              (json['lowStockAlertsCount'] as num?)?.toInt() ?? 0,
          dtcAlertsCount: (json['dtcAlertsCount'] as num?)?.toInt() ?? 0,
        ),
      _ => throw FormatException(
          'Invalid FinancialAnalyticsSnapshot payload: missing branchId or snapshotDate',
        ),
    };
  }

  /// Deserializes a list of financial analytics snapshots.
  static List<FinancialAnalyticsSnapshot> financialSnapshotListFromJson(
    List<dynamic> list,
  ) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(financialSnapshotFromJson)
        .toList();
  }

  /// Deserializes network executive summary using defensive numerical parsing.
  static NetworkAnalyticsSummary networkSummaryFromJson(
    Map<String, dynamic> json,
  ) {
    return NetworkAnalyticsSummary(
      totalActiveBranchesCount:
          (json['totalActiveBranchesCount'] as num?)?.toInt() ?? 0,
      totalNetworkRevenue:
          (json['totalNetworkRevenue'] as num?)?.toDouble() ?? 0.0,
      totalNetworkCompletedWorkOrders:
          (json['totalNetworkCompletedWorkOrders'] as num?)?.toInt() ?? 0,
      totalNetworkAppointments:
          (json['totalNetworkAppointments'] as num?)?.toInt() ?? 0,
      totalNetworkDtcAlerts:
          (json['totalNetworkDtcAlerts'] as num?)?.toInt() ?? 0,
    );
  }
}
