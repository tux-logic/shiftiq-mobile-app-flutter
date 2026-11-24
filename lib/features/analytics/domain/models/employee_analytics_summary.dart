/// Daily task completion count for the mechanic's 7-day productivity chart.
class EmployeeDailyCompletion {
  final DateTime date;
  final int count;

  const EmployeeDailyCompletion({
    required this.date,
    required this.count,
  });
}

/// Personal operational summary for an authenticated workshop employee
/// combining `GET /api/v1/analytics/me/employee-summary` and branch task details.
class EmployeeAnalyticsSummary {
  final String employeeId;
  final List<String> branchIds;
  final int assignedWorkOrdersCount;
  final int pendingTasksCount;
  final int inProgressTasksCount;
  final int completedTasksCount;
  final int activeDtcAlertsCount;
  final double? avgCompletionMinutes;
  final List<EmployeeDailyCompletion> weeklyCompletedTasks;
  final List<EmployeeAssignedWorkOrderSummary> assignedWorkOrders;

  const EmployeeAnalyticsSummary({
    required this.employeeId,
    this.branchIds = const [],
    this.assignedWorkOrdersCount = 0,
    this.pendingTasksCount = 0,
    this.inProgressTasksCount = 0,
    this.completedTasksCount = 0,
    this.activeDtcAlertsCount = 0,
    this.avgCompletionMinutes,
    this.weeklyCompletedTasks = const [],
    this.assignedWorkOrders = const [],
  });
}

/// Summary row for a single work order assigned to the authenticated employee.
class EmployeeAssignedWorkOrderSummary {
  final String workOrderId;
  final String branchId;
  final String vehicleId;
  final int internalNumber;
  final String status;
  final int assignedTasksCount;
  final int pendingTasksCount;

  const EmployeeAssignedWorkOrderSummary({
    required this.workOrderId,
    required this.branchId,
    required this.vehicleId,
    required this.internalNumber,
    required this.status,
    this.assignedTasksCount = 0,
    this.pendingTasksCount = 0,
  });
}
