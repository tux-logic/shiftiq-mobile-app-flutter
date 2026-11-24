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

  /// Parses an [EmployeeAnalyticsSummary] from `GET /api/v1/analytics/me/employee-summary`.
  static EmployeeAnalyticsSummary employeeSummaryFromJson(
    Map<String, dynamic> json,
  ) {
    final rawBranchIds = json['branchIds'];
    final branchIds = rawBranchIds is List
        ? rawBranchIds.map((e) => e.toString()).toList()
        : const <String>[];

    final rawOrders = json['assignedWorkOrders'];
    final assignedOrders = <EmployeeAssignedWorkOrderSummary>[];
    if (rawOrders is List) {
      for (final item in rawOrders.whereType<Map<String, dynamic>>()) {
        assignedOrders.add(
          EmployeeAssignedWorkOrderSummary(
            workOrderId: (item['workOrderId'] ?? '').toString(),
            branchId: (item['branchId'] ?? '').toString(),
            vehicleId: (item['vehicleId'] ?? '').toString(),
            internalNumber: (item['internalNumber'] as num?)?.toInt() ?? 0,
            status: (item['status'] ?? 'PENDING').toString(),
            assignedTasksCount:
                (item['assignedTasksCount'] as num?)?.toInt() ?? 0,
            pendingTasksCount:
                (item['pendingTasksCount'] as num?)?.toInt() ?? 0,
          ),
        );
      }
    }

    return EmployeeAnalyticsSummary(
      employeeId: (json['employeeId'] ?? '').toString(),
      branchIds: branchIds,
      assignedWorkOrdersCount:
          (json['assignedWorkOrdersCount'] as num?)?.toInt() ?? 0,
      pendingTasksCount: (json['pendingTasksCount'] as num?)?.toInt() ?? 0,
      completedTasksCount: (json['completedTasksCount'] as num?)?.toInt() ?? 0,
      activeDtcAlertsCount:
          (json['activeDtcAlertsCount'] as num?)?.toInt() ?? 0,
      assignedWorkOrders: assignedOrders,
    );
  }

  /// Deserializes `GET /api/v1/analytics/me/customer-summary`.
  static CustomerAnalyticsSummary customerSummaryFromJson(
    Map<String, dynamic> json,
  ) {
    final upcomingAppts = <CustomerUpcomingAppointment>[];
    final rawAppts = json['upcomingAppointments'];
    if (rawAppts is List) {
      for (final item in rawAppts.whereType<Map<String, dynamic>>()) {
        upcomingAppts.add(
          CustomerUpcomingAppointment(
            appointmentId: (item['appointmentId'] ?? '').toString(),
            branchId: (item['branchId'] ?? '').toString(),
            vehicleId: (item['vehicleId'] ?? '').toString(),
            scheduledStart: DateTime.tryParse(
              (item['scheduledStart'] ?? '').toString(),
            ),
            status: (item['status'] ?? 'PENDING').toString(),
          ),
        );
      }
    }

    final activeOrders = <CustomerActiveWorkOrder>[];
    final rawOrders = json['activeWorkOrders'];
    if (rawOrders is List) {
      for (final item in rawOrders.whereType<Map<String, dynamic>>()) {
        activeOrders.add(
          CustomerActiveWorkOrder(
            workOrderId: (item['workOrderId'] ?? '').toString(),
            branchId: (item['branchId'] ?? '').toString(),
            vehicleId: (item['vehicleId'] ?? '').toString(),
            internalNumber: (item['internalNumber'] as num?)?.toInt() ?? 0,
            status: (item['status'] ?? 'PENDING').toString(),
          ),
        );
      }
    }

    final pendingQuotes = <CustomerPendingQuote>[];
    final rawQuotes = json['pendingQuotes'];
    if (rawQuotes is List) {
      for (final item in rawQuotes.whereType<Map<String, dynamic>>()) {
        pendingQuotes.add(
          CustomerPendingQuote(
            quoteId: (item['quoteId'] ?? '').toString(),
            workOrderId: (item['workOrderId'] ?? '').toString(),
            branchId: (item['branchId'] ?? '').toString(),
            totalAmount: (item['totalAmount'] as num?)?.toDouble() ?? 0.0,
            status: (item['status'] ?? 'DRAFT').toString(),
          ),
        );
      }
    }

    return CustomerAnalyticsSummary(
      customerId: (json['customerId'] ?? '').toString(),
      activeVehiclesCount:
          (json['activeVehiclesCount'] as num?)?.toInt() ?? 0,
      activeDtcAlertsCount:
          (json['activeDtcAlertsCount'] as num?)?.toInt() ?? 0,
      upcomingAppointmentsCount:
          (json['upcomingAppointmentsCount'] as num?)?.toInt() ?? 0,
      activeWorkOrdersCount:
          (json['activeWorkOrdersCount'] as num?)?.toInt() ?? 0,
      pendingQuotesCount:
          (json['pendingQuotesCount'] as num?)?.toInt() ?? 0,
      upcomingAppointments: upcomingAppts,
      activeWorkOrders: activeOrders,
      pendingQuotes: pendingQuotes,
    );
  }
}
