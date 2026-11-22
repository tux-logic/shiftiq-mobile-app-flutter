/// Personal operational summary for an authenticated workshop employee
/// returned by `GET /api/v1/analytics/me/employee-summary`.
class EmployeeAnalyticsSummary {
  final String employeeId;
  final List<String> branchIds;
  final int assignedWorkOrdersCount;
  final int pendingTasksCount;
  final int completedTasksCount;
  final int activeDtcAlertsCount;
  final List<EmployeeAssignedWorkOrderSummary> assignedWorkOrders;

  const EmployeeAnalyticsSummary({
    required this.employeeId,
    this.branchIds = const [],
    this.assignedWorkOrdersCount = 0,
    this.pendingTasksCount = 0,
    this.completedTasksCount = 0,
    this.activeDtcAlertsCount = 0,
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
