import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/dtos/analytics_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';

/// ViewModel managing the mechanic's personal operational summary dashboard
/// backed by `GET /api/v1/analytics/me/employee-summary` with real work-order fallback.
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
      _summary = await _enrichFromBranchOrdersIfEmpty(parsed);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolves the employee's real task counts and assigned work orders from
  /// the active branch's work orders whenever `/analytics/me/employee-summary`
  /// returns empty counts (e.g., when tasks reference `employeeRegistrationId`).
  Future<EmployeeAnalyticsSummary> _enrichFromBranchOrdersIfEmpty(
    EmployeeAnalyticsSummary summary,
  ) async {
    final workOrdersUseCase = manageWorkOrders;
    final hasSummaryTasks =
        summary.assignedWorkOrders.isNotEmpty ||
        summary.pendingTasksCount > 0 ||
        summary.completedTasksCount > 0;
    if (hasSummaryTasks || workOrdersUseCase == null) {
      return summary;
    }

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

      var pendingCount = 0;
      var completedCount = 0;
      final assignedOrders = <EmployeeAssignedWorkOrderSummary>[];

      for (final order in branchOrders) {
        final myTasks = order.tasks
            .where((t) => employeeIds.contains(t.assignedMechanicId))
            .toList();
        if (myTasks.isEmpty) continue;

        final orderPending = myTasks.where((t) => !t.isCompleted).length;
        final orderCompleted = myTasks.where((t) => t.isCompleted).length;
        pendingCount += orderPending;
        completedCount += orderCompleted;

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

      if (assignedOrders.isEmpty) return summary;

      return EmployeeAnalyticsSummary(
        employeeId: summary.employeeId,
        branchIds: summary.branchIds.isNotEmpty
            ? summary.branchIds
            : [_activeBranchId],
        assignedWorkOrdersCount: assignedOrders.length,
        pendingTasksCount: pendingCount,
        completedTasksCount: completedCount,
        activeDtcAlertsCount: summary.activeDtcAlertsCount,
        assignedWorkOrders: assignedOrders,
      );
    } catch (_) {
      return summary;
    }
  }

  Future<void> refresh() => loadSummary();
}
