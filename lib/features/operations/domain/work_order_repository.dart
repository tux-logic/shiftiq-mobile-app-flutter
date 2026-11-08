import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_status.dart';

abstract class WorkOrderRepository {
  Future<List<WorkOrder>> getWorkOrders({
    required String branchId,
    WorkOrderStatus? status,
  });

  Future<WorkOrder> getWorkOrderById(String id);

  Future<WorkOrder> createWorkOrder({
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    String? appointmentId,
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    String customerName = 'Cliente General',
  });

  Future<WorkOrder> addTask({
    required String workOrderId,
    required String description,
    required double price,
    String? serviceId,
    String? mechanicId,
    String mechanicName = 'Sin asignar',
  });

  Future<WorkOrder> startTask(String taskId);

  Future<WorkOrder> completeTask(String taskId);

  Future<WorkOrder> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
    required double unitPrice,
    String productName = 'Repuesto',
  });

  Future<WorkOrder> completeWorkOrder(String workOrderId);
}

