import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/usecases/manage_products.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// ViewModel managing state for work order inspection, task progression, and product allocation.
class WorkOrderDetailViewModel extends ChangeNotifier {
  final ManageWorkOrders manageWorkOrders;
  final ManageWorkOrderTasks manageWorkOrderTasks;
  final ManageTaskProducts manageTaskProducts;
  final ManageProducts? manageProducts;

  WorkOrderDetailViewModel({
    required this.manageWorkOrders,
    required this.manageWorkOrderTasks,
    required this.manageTaskProducts,
    this.manageProducts,
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
      final loaded = await manageWorkOrders.getWorkOrderById(id);
      _order = await _hydrateTaskProductNames(loaded);
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

  /// Hydrates spare-part names from the branch inventory catalog whenever
  /// the backend work-order payload omits `productName`.
  Future<WorkOrder> _hydrateTaskProductNames(WorkOrder order) async {
    final productsUseCase = manageProducts;
    if (productsUseCase == null) return order;

    final needsHydration = order.tasks.any(
      (t) => t.products.any((p) => p.productName == 'Repuesto'),
    );
    if (!needsHydration) return order;

    try {
      final catalog = await productsUseCase.getProducts(branchId: order.branchId);
      final nameById = {for (final p in catalog) p.id: p.name};
      final updatedTasks = order.tasks.map((task) {
        final updatedProducts = task.products.map((tp) {
          if (tp.productName != 'Repuesto') return tp;
          final resolved = nameById[tp.productId];
          if (resolved == null || resolved.isEmpty) return tp;
          return tp.copyWith(productName: resolved);
        }).toList();
        return task.copyWith(products: updatedProducts);
      }).toList();
      return order.copyWith(tasks: updatedTasks);
    } catch (_) {
      return order;
    }
  }

  /// Loads real inventory products available in the active work order's branch.
  Future<List<Product>> loadBranchProducts() async {
    final order = _order;
    final productsUseCase = manageProducts;
    if (order == null || productsUseCase == null) return const [];
    return productsUseCase.getProducts(branchId: order.branchId);
  }

  Future<bool> addProduct({
    required String taskId,
    required String productId,
    String productName = '',
    required int quantity,
    double unitPrice = 0,
  }) async {
    _error = null;
    try {
      final updated = await manageTaskProducts.addProductToTask(
        taskId: taskId,
        productId: productId,
        quantity: quantity,
      );
      _order = await _hydrateTaskProductNames(updated);
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
