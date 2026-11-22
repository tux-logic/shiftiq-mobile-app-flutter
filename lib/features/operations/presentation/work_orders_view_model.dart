import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// ViewModel managing state and filtering for the workshop Work Orders dashboard.
class WorkOrdersViewModel extends ChangeNotifier {
  final ManageWorkOrders manageWorkOrders;
  final SessionStorage sessionStorage;
  final AnalyticsApi? analyticsApi;
  final EmployeeRegistrationApi? employeeRegistrationApi;

  WorkOrdersViewModel({
    required this.manageWorkOrders,
    required this.sessionStorage,
    this.analyticsApi,
    this.employeeRegistrationApi,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<WorkOrder> _allOrders = [];
  List<WorkOrder> _orders = [];
  List<WorkOrder> get orders => _orders;

  /// Returns orders filtered by [status] without mutating [statusFilter].
  List<WorkOrder> ordersForStatus(WorkOrderStatus? status) {
    if (status == null) return _allOrders;
    return _allOrders.where((o) => o.status == status).toList();
  }

  WorkOrderStatus? _statusFilter;
  WorkOrderStatus? get statusFilter => _statusFilter;

  String _activeBranchId = '';
  String get activeBranchId => _activeBranchId;

  String _activeBranchName = ApiConstants.defaultBranchName;
  String get activeBranchName => _activeBranchName;

  Future<void> init() async {
    _activeBranchId = await sessionStorage.getActiveBranchId() ?? ApiConstants.defaultBranchId;
    _activeBranchName =
        await sessionStorage.getActiveBranchName() ??
        ApiConstants.defaultBranchName;
    notifyListeners();
    await loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final branchOrders = await manageWorkOrders.getWorkOrders(
        branchId: _activeBranchId,
      );
      _allOrders = await _scopeOrdersForRole(branchOrders);
      _applyFilter();
    } catch (e) {
      _error = 'Error loading work orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<WorkOrder>> _scopeOrdersForRole(List<WorkOrder> branchOrders) async {
    if (analyticsApi == null) return branchOrders;

    try {
      final scope = RoleRouter.resolveScope(sessionStorage.roles);
      if (scope != MobileRoleScope.employee) {
        return branchOrders;
      }

      final summary = await analyticsApi!.getEmployeeSummary();
      final employeeId = (summary['employeeId'] ?? '').toString().trim();
      final employeeIds = <String>{if (employeeId.isNotEmpty) employeeId};

      final regApi = employeeRegistrationApi;
      if (regApi != null && employeeId.isNotEmpty) {
        try {
          final regs = await regApi.getEmployeeRegistrations(
            employeeId: employeeId,
          );
          for (final reg in regs) {
            final regId = (reg['id'] ?? '').toString().trim();
            if (regId.isNotEmpty) employeeIds.add(regId);
          }
        } catch (_) {}
      }

      final assignedOrderIds = <String>{};
      final rawAssigned = summary['assignedWorkOrders'];
      if (rawAssigned is List) {
        for (final item in rawAssigned) {
          if (item is Map<String, dynamic>) {
            final woId = (item['workOrderId'] ?? '').toString().trim();
            if (woId.isNotEmpty) assignedOrderIds.add(woId);
          }
        }
      }

      return branchOrders.where((order) {
        if (assignedOrderIds.contains(order.id)) return true;
        return order.tasks.any(
          (task) => employeeIds.contains(task.assignedMechanicId),
        );
      }).toList();
    } catch (_) {
      return branchOrders;
    }
  }

  void _applyFilter() {
    if (_statusFilter != null) {
      _orders = _allOrders.where((o) => o.status == _statusFilter).toList();
    } else {
      _orders = _allOrders;
    }
  }

  Future<void> setFilter(WorkOrderStatus? filter) async {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  Future<void> refresh() => loadOrders();
}
