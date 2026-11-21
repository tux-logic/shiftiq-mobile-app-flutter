import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/dtos/operations_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/service_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_task_api.dart';

/// Concrete implementation of [OperationsRepository] coordinating remote REST APIs
/// and mapping network payloads to pure domain entities.
class OperationsRepositoryImpl implements OperationsRepository {
  final ServiceApi serviceApi;
  final WorkOrderApi workOrderApi;
  final WorkOrderTaskApi workOrderTaskApi;

  const OperationsRepositoryImpl({
    required this.serviceApi,
    required this.workOrderApi,
    required this.workOrderTaskApi,
  });

  // ==========================================
  // Services Catalog
  // ==========================================

  @override
  Future<WorkshopService> createService({
    required String branchId,
    required String name,
    required double price,
  }) async {
    final raw = await serviceApi.createService(
      branchId: branchId,
      name: name,
      price: price,
    );
    return OperationsDto.workshopServiceFromJson(raw);
  }

  @override
  Future<List<WorkshopService>> getBranchServices(String branchId) async {
    final rawList = await serviceApi.getBranchServices(branchId);
    return OperationsDto.workshopServiceListFromJson(rawList);
  }

  @override
  Future<WorkshopService> updateService({
    required String serviceId,
    required String name,
    required double price,
  }) async {
    final raw = await serviceApi.updateService(
      serviceId: serviceId,
      name: name,
      price: price,
    );
    return OperationsDto.workshopServiceFromJson(raw);
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await serviceApi.deleteService(serviceId);
  }

  // ==========================================
  // Work Orders Lifecycle
  // ==========================================

  @override
  Future<WorkOrder> createWorkOrder({
    required String appointmentId,
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    List<String> entryInspectionImages = const [],
  }) async {
    final raw = await workOrderApi.createWorkOrder(
      appointmentId: appointmentId,
      branchId: branchId,
      vehicleId: vehicleId,
      customerId: customerId,
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      entryInspectionImages: entryInspectionImages,
    );
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<List<WorkOrder>> getWorkOrders({
    String? branchId,
    String? vehicleId,
  }) async {
    final rawList = await workOrderApi.getWorkOrders(
      branchId: branchId,
      vehicleId: vehicleId,
    );
    return OperationsDto.workOrderListFromJson(rawList);
  }

  @override
  Future<WorkOrder> getWorkOrderById(String id) async {
    final raw = await workOrderApi.getWorkOrderById(id);
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<WorkOrder> updateWorkOrderIntake({
    required String id,
    required String diagnosticSummary,
    required int mileageIn,
    List<String>? entryInspectionImages,
  }) async {
    final raw = await workOrderApi.updateWorkOrderIntake(
      id: id,
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      entryInspectionImages: entryInspectionImages,
    );
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<WorkOrder> completeWorkOrder(String id) async {
    final raw = await workOrderApi.completeWorkOrder(id);
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<void> deleteWorkOrder(String id) async {
    await workOrderApi.deleteWorkOrder(id);
  }

  // ==========================================
  // Work Order Tasks
  // ==========================================

  @override
  Future<WorkOrder> addTaskToWorkOrder({
    required String workOrderId,
    required String serviceId,
    required String assignedMechanicId,
    required String description,
    List<String> evidenceImages = const [],
  }) async {
    final raw = await workOrderTaskApi.addTask(
      workOrderId: workOrderId,
      serviceId: serviceId,
      assignedMechanicId: assignedMechanicId,
      description: description,
      evidenceImages: evidenceImages,
    );
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<WorkOrderTask> updateTaskDetails({
    required String workOrderId,
    required String taskId,
    String? serviceId,
    String? assignedMechanicId,
    String? description,
    List<String>? evidenceImages,
  }) async {
    final raw = await workOrderTaskApi.updateTaskDetails(
      workOrderId: workOrderId,
      taskId: taskId,
      serviceId: serviceId,
      assignedMechanicId: assignedMechanicId,
      description: description,
      evidenceImages: evidenceImages,
    );
    return OperationsDto.workOrderTaskFromJson(raw);
  }

  @override
  Future<void> deleteTask({
    required String workOrderId,
    required String taskId,
  }) async {
    await workOrderTaskApi.deleteTask(
      workOrderId: workOrderId,
      taskId: taskId,
    );
  }

  @override
  Future<WorkOrder> assignMechanicToTask({
    required String taskId,
    required String mechanicId,
  }) async {
    final raw = await workOrderTaskApi.assignMechanic(
      taskId: taskId,
      mechanicId: mechanicId,
    );
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<WorkOrder> startTask(String taskId) async {
    final raw = await workOrderTaskApi.startTask(taskId);
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<WorkOrder> completeTask(String taskId) async {
    final raw = await workOrderTaskApi.completeTask(taskId);
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<WorkOrder> reopenTask(String taskId) async {
    final raw = await workOrderTaskApi.reopenTask(taskId);
    return OperationsDto.workOrderFromJson(raw);
  }

  // ==========================================
  // Task Products & Stock Reservations
  // ==========================================

  @override
  Future<WorkOrder> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
  }) async {
    final raw = await workOrderTaskApi.addProductToTask(
      taskId: taskId,
      productId: productId,
      quantity: quantity,
    );
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<WorkOrder> updateTaskProductQuantity({
    required String taskId,
    required String productId,
    required int quantity,
  }) async {
    final raw = await workOrderTaskApi.updateTaskProductQuantity(
      taskId: taskId,
      productId: productId,
      quantity: quantity,
    );
    return OperationsDto.workOrderFromJson(raw);
  }

  @override
  Future<void> removeProductFromTask({
    required String taskId,
    required String productId,
  }) async {
    await workOrderTaskApi.removeProductFromTask(
      taskId: taskId,
      productId: productId,
    );
  }
}

/// Backward compatibility alias.
typedef WorkOrderRepositoryImpl = OperationsRepositoryImpl;
