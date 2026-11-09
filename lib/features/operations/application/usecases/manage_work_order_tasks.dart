import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Application use case to manage mechanical repair tasks, mechanic assignments, and task status transitions.
class ManageWorkOrderTasks {
  final OperationsRepository repository;

  const ManageWorkOrderTasks({required this.repository});

  /// Adds a new mechanical task to an existing work order.
  Future<WorkOrder> addTask({
    required String workOrderId,
    required String serviceId,
    required String assignedMechanicId,
    required String description,
    List<String> evidenceImages = const [],
  }) async {
    final trimmedOrderId = workOrderId.trim();
    final trimmedServiceId = serviceId.trim();
    final trimmedMechanicId = assignedMechanicId.trim();
    final trimmedDesc = description.trim();

    if (trimmedOrderId.isEmpty) {
      throw ArgumentError('Work Order ID cannot be empty.');
    }
    if (trimmedServiceId.isEmpty) {
      throw ArgumentError('Service ID cannot be empty.');
    }
    if (trimmedMechanicId.isEmpty) {
      throw ArgumentError('Assigned mechanic ID cannot be empty.');
    }
    if (trimmedDesc.length < 5) {
      throw ArgumentError('Task description must be at least 5 characters long.');
    }

    return repository.addTaskToWorkOrder(
      workOrderId: trimmedOrderId,
      serviceId: trimmedServiceId,
      assignedMechanicId: trimmedMechanicId,
      description: trimmedDesc,
      evidenceImages: evidenceImages,
    );
  }

  /// Updates details of an existing repair task.
  Future<WorkOrderTask> updateTaskDetails({
    required String workOrderId,
    required String taskId,
    String? serviceId,
    String? assignedMechanicId,
    String? description,
    List<String>? evidenceImages,
  }) async {
    final trimmedOrderId = workOrderId.trim();
    final trimmedTaskId = taskId.trim();

    if (trimmedOrderId.isEmpty) {
      throw ArgumentError('Work Order ID cannot be empty.');
    }
    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }

    return repository.updateTaskDetails(
      workOrderId: trimmedOrderId,
      taskId: trimmedTaskId,
      serviceId: serviceId?.trim(),
      assignedMechanicId: assignedMechanicId?.trim(),
      description: description?.trim(),
      evidenceImages: evidenceImages,
    );
  }

  /// Deletes a task from the work order and releases any product stock reservations.
  Future<void> deleteTask({
    required String workOrderId,
    required String taskId,
  }) async {
    final trimmedOrderId = workOrderId.trim();
    final trimmedTaskId = taskId.trim();

    if (trimmedOrderId.isEmpty) {
      throw ArgumentError('Work Order ID cannot be empty.');
    }
    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }

    return repository.deleteTask(
      workOrderId: trimmedOrderId,
      taskId: trimmedTaskId,
    );
  }

  /// Reassigns technician responsible for executing the repair task.
  Future<WorkOrder> assignMechanic({
    required String taskId,
    required String mechanicId,
  }) async {
    final trimmedTaskId = taskId.trim();
    final trimmedMechanicId = mechanicId.trim();

    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }
    if (trimmedMechanicId.isEmpty) {
      throw ArgumentError('Mechanic ID cannot be empty.');
    }

    return repository.assignMechanicToTask(
      taskId: trimmedTaskId,
      mechanicId: trimmedMechanicId,
    );
  }

  /// Starts a pending task, transitioning it to DOING status.
  Future<WorkOrder> startTask(String taskId) async {
    final trimmedTaskId = taskId.trim();
    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }

    return repository.startTask(trimmedTaskId);
  }

  /// Completes a task currently in DOING status.
  Future<WorkOrder> completeTask(String taskId) async {
    final trimmedTaskId = taskId.trim();
    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }

    return repository.completeTask(trimmedTaskId);
  }

  /// Reopens a previously completed task back to DOING status.
  Future<WorkOrder> reopenTask(String taskId) async {
    final trimmedTaskId = taskId.trim();
    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }

    return repository.reopenTask(trimmedTaskId);
  }
}
