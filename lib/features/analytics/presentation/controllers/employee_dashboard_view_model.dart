import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/dtos/analytics_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';

/// ViewModel managing the mechanic's personal operational summary dashboard
/// combining `GET /api/v1/analytics/me/employee-summary` with live branch task metrics.
class EmployeeDashboardViewModel extends ChangeNotifier {
  final AnalyticsApi analyticsApi;
  final SessionStorage sessionStorage;
  final ManageWorkOrders? manageWorkOrders;
  final EmployeeRegistrationApi? employeeRegistrationApi;

  EmployeeDashboardViewModel({
    required this.analyticsApi,
    required this.sessionStorage,
    this.manageWorkOrders,
    this.employeeRegistrationApi,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _activeBranchId = ApiConstants.defaultBranchId;
  String _activeBranchName = ApiConstants.defaultBranchName;
  String get activeBranchName => _activeBranchName;

  EmployeeAnalyticsSummary? _summary;
  EmployeeAnalyticsSummary? get summary => _summary;

  Future<void> init() async {
    _activeBranchId =
        await sessionStorage.getActiveBranchId() ??
        ApiConstants.defaultBranchId;
    _activeBranchName =
        await sessionStorage.getActiveBranchName() ??
        ApiConstants.defaultBranchName;
    notifyListeners();
    await loadSummary();
  }

  Future<void> loadSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await analyticsApi.getEmployeeSummary();
      final parsed = AnalyticsDto.employeeSummaryFromJson(raw);
      _summary = await _enrichWithBranchTaskMetrics(parsed);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Combines `/analytics/me/employee-summary` with real branch task timestamps
  /// and statuses (`PENDING` / `DOING` / `COMPLETED`, 7-day completion trend,
  /// and average execution duration).
  Future<EmployeeAnalyticsSummary> _enrichWithBranchTaskMetrics(
    EmployeeAnalyticsSummary summary,
  ) async {
    final workOrdersUseCase = manageWorkOrders;
    if (workOrdersUseCase == null) return summary;

    try {
      final employeeIds = <String>{
        if (summary.employeeId.isNotEmpty) summary.employeeId,
      };
      final regApi = employeeRegistrationApi;
      if (regApi != null && summary.employeeId.isNotEmpty) {
        try {
          final regs = await regApi.getEmployeeRegistrations(
            employeeId: summary.employeeId,
          );
          for (final reg in regs) {
            final regId = (reg['id'] ?? '').toString().trim();
            if (regId.isNotEmpty) employeeIds.add(regId);
          }
        } catch (_) {}
      }
      if (employeeIds.isEmpty) return summary;

      final branchOrders = await workOrdersUseCase.getWorkOrders(
        branchId: _activeBranchId,
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dayCounts = <DateTime, int>{
        for (int i = 6; i >= 0; i--) today.subtract(Duration(days: i)): 0,
      };

      var pendingCount = 0;
      var inProgressCount = 0;
      var completedCount = 0;
      var durationMinutesSum = 0;
      var durationSampleCount = 0;
      final assignedOrders = <EmployeeAssignedWorkOrderSummary>[];

      for (final order in branchOrders) {
        final myTasks = order.tasks
            .where((t) => employeeIds.contains(t.assignedMechanicId))
            .toList();
        if (myTasks.isEmpty) continue;

        final orderPending = myTasks.where((t) => !t.isCompleted).length;
        for (final task in myTasks) {
          if (task.isCompleted) {
            completedCount++;
            final completedAt = task.completedAt?.toLocal();
            if (completedAt != null) {
              final dayKey = DateTime(
                completedAt.year,
                completedAt.month,
                completedAt.day,
              );
              if (dayCounts.containsKey(dayKey)) {
                dayCounts[dayKey] = dayCounts[dayKey]! + 1;
              }
              final startedAt = task.startedAt?.toLocal();
              if (startedAt != null && !completedAt.isBefore(startedAt)) {
                durationMinutesSum +=
                    completedAt.difference(startedAt).inMinutes;
                durationSampleCount++;
              }
            }
          } else if (task.isInProgress) {
            inProgressCount++;
          } else {
            pendingCount++;
          }
        }

        assignedOrders.add(
          EmployeeAssignedWorkOrderSummary(
            workOrderId: order.id,
            branchId: order.branchId,
            vehicleId: order.vehicleId,
            internalNumber: order.internalNumber,
            status: order.status.value,
            assignedTasksCount: myTasks.length,
            pendingTasksCount: orderPending,
          ),
        );
      }

      final weekly = dayCounts.entries
          .map((e) => EmployeeDailyCompletion(date: e.key, count: e.value))
          .toList();

      final avgMinutes = durationSampleCount > 0
          ? durationMinutesSum / durationSampleCount
          : null;

      if (assignedOrders.isEmpty &&
          (summary.pendingTasksCount > 0 || summary.completedTasksCount > 0)) {
        return EmployeeAnalyticsSummary(
          employeeId: summary.employeeId,
          branchIds: summary.branchIds,
          assignedWorkOrdersCount: summary.assignedWorkOrdersCount,
          pendingTasksCount: summary.pendingTasksCount,
          inProgressTasksCount: 0,
          completedTasksCount: summary.completedTasksCount,
          activeDtcAlertsCount: summary.activeDtcAlertsCount,
          weeklyCompletedTasks: weekly,
          assignedWorkOrders: summary.assignedWorkOrders,
        );
      }

      return EmployeeAnalyticsSummary(
        employeeId: summary.employeeId,
        branchIds: summary.branchIds.isNotEmpty
            ? summary.branchIds
            : [_activeBranchId],
        assignedWorkOrdersCount: assignedOrders.length,
        pendingTasksCount: pendingCount,
        inProgressTasksCount: inProgressCount,
        completedTasksCount: completedCount,
        activeDtcAlertsCount: summary.activeDtcAlertsCount,
        avgCompletionMinutes: avgMinutes,
        weeklyCompletedTasks: weekly,
        assignedWorkOrders: assignedOrders,
      );
    } catch (_) {
      return summary;
    }
  }

  Future<void> refresh() => loadSummary();
}
