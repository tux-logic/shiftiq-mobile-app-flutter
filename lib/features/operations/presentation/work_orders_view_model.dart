import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// ViewModel managing state and filtering for the workshop Work Orders dashboard.
class WorkOrdersViewModel extends ChangeNotifier {
  final ManageWorkOrders manageWorkOrders;
  final SessionStorage sessionStorage;

  WorkOrdersViewModel({
    required this.manageWorkOrders,
    required this.sessionStorage,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<WorkOrder> _orders = [];
  List<WorkOrder> get orders => _orders;

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
      final fetchedOrders = await manageWorkOrders.getWorkOrders(
        branchId: _activeBranchId,
      );

      if (_statusFilter != null) {
        _orders = fetchedOrders.where((o) => o.status == _statusFilter).toList();
      } else {
        _orders = fetchedOrders;
      }
    } catch (e) {
      _error = 'Error loading work orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFilter(WorkOrderStatus? filter) async {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    notifyListeners();
    await loadOrders();
  }

  Future<void> refresh() => loadOrders();
}
