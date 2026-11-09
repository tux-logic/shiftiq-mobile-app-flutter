import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// ViewModel managing state for work order inspection, task progression, and product allocation.
class WorkOrderDetailViewModel extends ChangeNotifier {
  final ManageWorkOrders manageWorkOrders;
  final ManageWorkOrderTasks manageWorkOrderTasks;
  final ManageTaskProducts manageTaskProducts;

  WorkOrderDetailViewModel({
    required this.manageWorkOrders,
    required this.manageWorkOrderTasks,
    required this.manageTaskProducts,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  WorkOrder? _order;
  WorkOrder? get order => _order;

  Future<void> loadOrder(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _order = await manageWorkOrders.getWorkOrderById(id);
    } catch (e) {
      _error = 'Error loading work order detail: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startTask(String taskId) async {
    try {
      _order = await manageWorkOrderTasks.startTask(taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error starting task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTask(String taskId) async {
    try {
      _order = await manageWorkOrderTasks.completeTask(taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error completing task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reopenTask(String taskId) async {
    try {
      _order = await manageWorkOrderTasks.reopenTask(taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error reopening task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTask({
    required String description,
    required double price,
    String? serviceId,
    String? mechanicId,
    String mechanicName = 'Sin asignar',
  }) async {
    if (_order == null) return false;

    try {
      _order = await manageWorkOrderTasks.addTask(
        workOrderId: _order!.id,
        serviceId: serviceId ?? 'srv-default',
        assignedMechanicId: mechanicId ?? 'ereg-unassigned',
        description: description,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error adding task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct({
    required String taskId,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      _order = await manageTaskProducts.addProductToTask(
        taskId: taskId,
        productId: productId,
        quantity: quantity,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error dispatching replacement part: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeOrder() async {
    if (_order == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _order = await manageWorkOrders.completeWorkOrder(_order!.id);
      return true;
    } catch (e) {
      _error = 'Error closing work order: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
