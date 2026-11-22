import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
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
  final CoreRepository? coreRepository;
  final EmployeeRegistrationApi? employeeRegistrationApi;

  WorkOrderDetailViewModel({
    required this.manageWorkOrders,
    required this.manageWorkOrderTasks,
    required this.manageTaskProducts,
    this.manageProducts,
    this.coreRepository,
    this.employeeRegistrationApi,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  WorkOrder? _order;
  WorkOrder? get order => _order;

  Set<String> _currentEmployeeIds = const {};
  bool _employeeIdentityLoaded = false;

  /// Returns whether the current employee is allowed to execute [task].
  /// When identity context is unavailable (e.g. unit tests), defaults to true.
  bool canExecuteTask(WorkOrderTask task) {
    if (!_employeeIdentityLoaded || _currentEmployeeIds.isEmpty) return true;
    return _currentEmployeeIds.contains(task.assignedMechanicId);
  }

  Future<void> loadOrder(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadCurrentEmployeeIdentity();
      final loaded = await manageWorkOrders.getWorkOrderById(id);
      _order = await _hydrateOrderDetails(loaded);
    } catch (e) {
      _error = 'Error loading work order detail: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startTask(String taskId) async {
    try {
      final updated = await manageWorkOrderTasks.startTask(taskId);
      _order = await _hydrateOrderDetails(updated);
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
      final updated = await manageWorkOrderTasks.completeTask(taskId);
      _order = await _hydrateOrderDetails(updated);
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
      final updated = await manageWorkOrderTasks.reopenTask(taskId);
      _order = await _hydrateOrderDetails(updated);
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

  Future<void> _loadCurrentEmployeeIdentity() async {
    if (_employeeIdentityLoaded) return;
    final coreRepo = coreRepository;
    if (coreRepo == null) return;

    try {
      final profile = await coreRepo.getMyProfileContext();
      final employee = profile.employee;
      if (employee == null) {
        _employeeIdentityLoaded = true;
        return;
      }
      final ids = <String>{employee.employeeId};
      final regApi = employeeRegistrationApi;
      if (regApi != null) {
        final regs = await regApi.getEmployeeRegistrations(
          employeeId: employee.employeeId,
        );
        for (final reg in regs) {
          final regId = (reg['id'] ?? '').toString().trim();
          if (regId.isNotEmpty) ids.add(regId);
        }
      }
      _currentEmployeeIds = ids;
      _employeeIdentityLoaded = true;
    } catch (_) {
      // Keep default permissive check if profile lookup fails transiently.
    }
  }

  Future<WorkOrder> _hydrateOrderDetails(WorkOrder order) async {
    var hydrated = await _hydrateTaskProductNames(order);
    hydrated = await _hydrateTaskMechanicNames(hydrated);
    return hydrated;
  }

  /// Hydrates mechanic names from branch registrations & employee profiles
  /// whenever the backend task payload omits `assignedMechanicName`.
  Future<WorkOrder> _hydrateTaskMechanicNames(WorkOrder order) async {
    final coreRepo = coreRepository;
    if (coreRepo == null) return order;

    final needsHydration = order.tasks.any(
      (t) =>
          t.assignedMechanicName == 'Sin asignar' &&
          t.assignedMechanicId.isNotEmpty,
    );
    if (!needsHydration) return order;

    try {
      final regToEmployeeId = <String, String>{};
      final regApi = employeeRegistrationApi;
      if (regApi != null) {
        final regs = await regApi.getEmployeeRegistrations(
          branchId: order.branchId,
        );
        for (final reg in regs) {
          final regId = (reg['id'] ?? '').toString().trim();
          final empId = (reg['employeeId'] ?? '').toString().trim();
          if (regId.isNotEmpty && empId.isNotEmpty) {
            regToEmployeeId[regId] = empId;
          }
        }
      }

      final nameCache = <String, String>{};
      final updatedTasks = <WorkOrderTask>[];
      for (final task in order.tasks) {
        if (task.assignedMechanicName != 'Sin asignar' ||
            task.assignedMechanicId.isEmpty) {
          updatedTasks.add(task);
          continue;
        }
        final targetEmpId =
            regToEmployeeId[task.assignedMechanicId] ?? task.assignedMechanicId;
        var resolvedName = nameCache[targetEmpId];
        if (resolvedName == null) {
          try {
            final empJson = await coreRepo.getEmployeeById(targetEmpId);
            final first = (empJson['firstName'] ?? '').toString().trim();
            final last = (empJson['lastName'] ?? '').toString().trim();
            final full = [first, last].where((s) => s.isNotEmpty).join(' ');
            if (full.isNotEmpty) {
              resolvedName = full;
              nameCache[targetEmpId] = full;
            }
          } catch (_) {}
        }
        updatedTasks.add(
          resolvedName != null
              ? task.copyWith(assignedMechanicName: resolvedName)
              : task,
        );
      }
      return order.copyWith(tasks: updatedTasks);
    } catch (_) {
      return order;
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
      _order = await _hydrateOrderDetails(updated);
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
