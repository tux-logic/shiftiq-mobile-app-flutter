import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/dtos/analytics_dto.dart';

void main() {
  test('employeeSummaryFromJson parses KPIs and assignedWorkOrders', () {
    final summary = AnalyticsDto.employeeSummaryFromJson({
      'employeeId': 'emp-1',
      'branchIds': ['branch-1'],
      'assignedWorkOrdersCount': 2,
      'pendingTasksCount': 3,
      'completedTasksCount': 5,
      'activeDtcAlertsCount': 1,
      'assignedWorkOrders': [
        {
          'workOrderId': 'wo-1',
          'branchId': 'branch-1',
          'vehicleId': 'veh-1',
          'internalNumber': 1042,
          'status': 'IN_PROGRESS',
          'assignedTasksCount': 2,
          'pendingTasksCount': 1,
        },
      ],
    });

    expect(summary.employeeId, 'emp-1');
    expect(summary.branchIds, ['branch-1']);
    expect(summary.assignedWorkOrdersCount, 2);
    expect(summary.pendingTasksCount, 3);
    expect(summary.completedTasksCount, 5);
    expect(summary.activeDtcAlertsCount, 1);
    expect(summary.assignedWorkOrders.length, 1);
    expect(summary.assignedWorkOrders.first.internalNumber, 1042);
    expect(summary.assignedWorkOrders.first.status, 'IN_PROGRESS');
  });
}
