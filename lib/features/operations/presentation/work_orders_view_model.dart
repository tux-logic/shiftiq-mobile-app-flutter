import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/get_work_orders_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_status.dart';

class WorkOrdersViewModel extends ChangeNotifier {
  final GetWorkOrdersUseCase getWorkOrdersUseCase;
  final SessionStorage sessionStorage;

  WorkOrdersViewModel({
    required this.getWorkOrdersUseCase,
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

  String _activeBranchName = 'Sede Principal';
  String get activeBranchName => _activeBranchName;

  Future<void> init() async {
    _activeBranchId = await sessionStorage.getActiveBranchId() ?? 'b-01-smp';
    _activeBranchName =
        await sessionStorage.getActiveBranchName() ??
        'Sede Central - San Martín de Porres';
    notifyListeners();
    await loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await getWorkOrdersUseCase.execute(
        branchId: _activeBranchId,
        status: _statusFilter,
      );
    } catch (e) {
      _error = 'Error al cargar órdenes de trabajo: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(WorkOrderStatus? filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    notifyListeners();
    loadOrders();
  }

  Future<void> refresh() => loadOrders();
}
