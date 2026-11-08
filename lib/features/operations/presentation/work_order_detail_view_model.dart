import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/add_task_to_work_order_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/finalize_operations_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/get_work_order_detail_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/manage_task_status_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';

class WorkOrderDetailViewModel extends ChangeNotifier {
  final GetWorkOrderDetailUseCase getWorkOrderDetailUseCase;
  final StartTaskUseCase startTaskUseCase;
  final CompleteTaskUseCase completeTaskUseCase;
  final AddTaskToWorkOrderUseCase addTaskUseCase;
  final AddProductToTaskUseCase addProductUseCase;
  final CompleteWorkOrderUseCase completeWorkOrderUseCase;

  WorkOrderDetailViewModel({
    required this.getWorkOrderDetailUseCase,
    required this.startTaskUseCase,
    required this.completeTaskUseCase,
    required this.addTaskUseCase,
    required this.addProductUseCase,
    required this.completeWorkOrderUseCase,
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
      _order = await getWorkOrderDetailUseCase.execute(id);
    } catch (e) {
      _error = 'Error al cargar detalle de la orden: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startTask(String taskId) async {
    try {
      _order = await startTaskUseCase.execute(taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al iniciar tarea: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTask(String taskId) async {
    try {
      _order = await completeTaskUseCase.execute(taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al completar tarea: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTask({
    required String description,
    required double price,
    String? mechanicId,
    String mechanicName = 'Sin asignar',
  }) async {
    if (_order == null) return false;

    try {
      _order = await addTaskUseCase.execute(
        workOrderId: _order!.id,
        description: description,
        price: price,
        mechanicId: mechanicId,
        mechanicName: mechanicName,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar tarea: ${e.toString()}';
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
      _order = await addProductUseCase.execute(
        taskId: taskId,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al despachar repuesto: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeOrder() async {
    if (_order == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _order = await completeWorkOrderUseCase.execute(_order!.id);
      return true;
    } catch (e) {
      _error = 'Error al liquidar orden: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
