import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Contract interface defining data access and operations for the Operations Bounded Context.
abstract class OperationsRepository {
  // --- Services Catalog ---
  Future<WorkshopService> createService({
    required String branchId,
    required String name,
    required double price,
  });

  Future<List<WorkshopService>> getBranchServices(String branchId);

  Future<WorkshopService> updateService({
    required String serviceId,
    required String name,
    required double price,
  });

  Future<void> deleteService(String serviceId);

  // --- Work Orders ---
  Future<WorkOrder> createWorkOrder({
    required String appointmentId,
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    List<String> entryInspectionImages = const [],
  });

  Future<List<WorkOrder>> getWorkOrders({
    String? branchId,
    String? vehicleId,
  });

  Future<WorkOrder> getWorkOrderById(String id);

  Future<WorkOrder> updateWorkOrderIntake({
    required String id,
    required String diagnosticSummary,
    required int mileageIn,
    List<String>? entryInspectionImages,
  });

  Future<WorkOrder> completeWorkOrder(String id);

  Future<void> deleteWorkOrder(String id);

  // --- Work Order Tasks ---
  Future<WorkOrder> addTaskToWorkOrder({
    required String workOrderId,
    required String serviceId,
    required String assignedMechanicId,
    required String description,
    List<String> evidenceImages = const [],
  });

  Future<WorkOrderTask> updateTaskDetails({
    required String workOrderId,
    required String taskId,
    String? serviceId,
    String? assignedMechanicId,
    String? description,
    List<String>? evidenceImages,
  });

  Future<void> deleteTask({
    required String workOrderId,
    required String taskId,
  });

  Future<WorkOrder> assignMechanicToTask({
    required String taskId,
    required String mechanicId,
  });

  Future<WorkOrder> startTask(String taskId);

  Future<WorkOrder> completeTask(String taskId);

  Future<WorkOrder> reopenTask(String taskId);

  // --- Task Products (Inventory Stock Reservations) ---
  Future<WorkOrder> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
  });

  Future<WorkOrder> updateTaskProductQuantity({
    required String taskId,
    required String productId,
    required int quantity,
  });

  Future<void> removeProductFromTask({
    required String taskId,
    required String productId,
  });
}

/// Backward compatibility alias.
typedef WorkOrderRepository = OperationsRepository;
