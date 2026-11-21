import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP client consuming Work Order Tasks and Product stock reservation endpoints.
class WorkOrderTaskApi {
  final ApiClient apiClient;

  const WorkOrderTaskApi({required this.apiClient});

  /// POST /api/v1/work-orders/{id}/tasks
  /// Adds a repair task to a work order.
  Future<Map<String, dynamic>> addTask({
    required String workOrderId,
    required String serviceId,
    required String assignedMechanicId,
    required String description,
    List<String> evidenceImages = const [],
  }) async {
    final response = await apiClient.post(
      ApiConstants.workOrderTasks(workOrderId),
      body: {
        'serviceId': serviceId,
        'assignedMechanicId': assignedMechanicId,
        'description': description,
        'evidenceImages': evidenceImages,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/work-orders/{id}/tasks/{taskId}
  /// Modifies labor task attributes.
  Future<Map<String, dynamic>> updateTaskDetails({
    required String workOrderId,
    required String taskId,
    String? serviceId,
    String? assignedMechanicId,
    String? description,
    List<String>? evidenceImages,
  }) async {
    final response = await apiClient.put(
      ApiConstants.workOrderTaskById(workOrderId, taskId),
      body: {
        'serviceId': ?serviceId,
        'assignedMechanicId': ?assignedMechanicId,
        'description': ?description,
        'evidenceImages': ?evidenceImages,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/work-orders/{id}/tasks/{taskId}
  /// Deletes task and releases product stock reservations.
  Future<void> deleteTask({
    required String workOrderId,
    required String taskId,
  }) async {
    await apiClient.delete(ApiConstants.workOrderTaskById(workOrderId, taskId));
  }

  /// POST /api/v1/work-order-tasks/{taskId}/assign-mechanic?mechanicId={mechanicId}
  /// Reassigns responsible technician.
  Future<Map<String, dynamic>> assignMechanic({
    required String taskId,
    required String mechanicId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.workOrderTaskAssignMechanic(taskId, mechanicId),
    );
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/work-order-tasks/{taskId}/start
  /// Transitions task status PENDING -> DOING.
  Future<Map<String, dynamic>> startTask(String taskId) async {
    final response = await apiClient.post(ApiConstants.workOrderTaskStart(taskId));
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/work-order-tasks/{taskId}/complete
  /// Transitions task status DOING -> COMPLETED.
  Future<Map<String, dynamic>> completeTask(String taskId) async {
    final response = await apiClient.post(ApiConstants.workOrderTaskComplete(taskId));
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/work-order-tasks/{taskId}/reopen
  /// Reverts task status COMPLETED -> DOING.
  Future<Map<String, dynamic>> reopenTask(String taskId) async {
    final response = await apiClient.post(ApiConstants.workOrderTaskReopen(taskId));
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/work-order-tasks/{taskId}/products
  /// Attaches an inventory spare part product and reserves FIFO branch stock.
  Future<Map<String, dynamic>> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
  }) async {
    final response = await apiClient.post(
      ApiConstants.workOrderTaskProducts(taskId),
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/work-order-tasks/{taskId}/products/{productId}
  /// Modifies reserved product quantity.
  Future<Map<String, dynamic>> updateTaskProductQuantity({
    required String taskId,
    required String productId,
    required int quantity,
  }) async {
    final response = await apiClient.put(
      ApiConstants.workOrderTaskProductById(taskId, productId),
      body: {
        'quantity': quantity,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/work-order-tasks/{taskId}/products/{productId}
  /// Detaches replacement product and immediately releases stock reservations back to batches.
  Future<void> removeProductFromTask({
    required String taskId,
    required String productId,
  }) async {
    await apiClient.delete(ApiConstants.workOrderTaskProductById(taskId, productId));
  }
}
