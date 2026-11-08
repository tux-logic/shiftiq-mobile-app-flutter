import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_dto.dart';

class WorkOrderApi {
  final ApiClient apiClient;

  WorkOrderApi({required this.apiClient});

  Future<List<WorkOrderDto>> getWorkOrders({
    required String branchId,
    String? status,
  }) async {
    var url = '${ApiConstants.workOrders}?branchId=$branchId';
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    final response = await apiClient.get(url);
    if (response is List) {
      return response
          .map((item) => WorkOrderDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<WorkOrderDto> getWorkOrderById(String id) async {
    final response = await apiClient.get(ApiConstants.workOrderDetails(id));
    return WorkOrderDto.fromJson(response as Map<String, dynamic>);
  }

  Future<WorkOrderDto> createWorkOrder({
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    String? appointmentId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.workOrders,
      body: {
        'branchId': branchId,
        'vehicleId': vehicleId,
        'customerId': customerId,
        'diagnosticSummary': diagnosticSummary,
        'mileageIn': mileageIn,
        'appointmentId': appointmentId,
        'entryInspectionImages': <String>[],
      },
    );
    return WorkOrderDto.fromJson(response as Map<String, dynamic>);
  }

  Future<WorkOrderDto> addTask({
    required String workOrderId,
    required String description,
    required double price,
    String? serviceId,
    String? mechanicId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.workOrderTasks(workOrderId),
      body: {
        'description': description,
        'price': price,
        'serviceId': serviceId,
        'assignedMechanicId': mechanicId,
      },
    );
    return WorkOrderDto.fromJson(response as Map<String, dynamic>);
  }

  Future<WorkOrderDto> startTask(String taskId) async {
    final response = await apiClient.post('/api/v1/work-order-tasks/$taskId/start');
    return WorkOrderDto.fromJson(response as Map<String, dynamic>);
  }

  Future<WorkOrderDto> completeTask(String taskId) async {
    final response =
        await apiClient.post('/api/v1/work-order-tasks/$taskId/complete');
    return WorkOrderDto.fromJson(response as Map<String, dynamic>);
  }

  Future<WorkOrderDto> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
    required double unitPrice,
  }) async {
    final response = await apiClient.post(
      ApiConstants.workOrderTaskProducts(taskId),
      body: {
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
      },
    );
    return WorkOrderDto.fromJson(response as Map<String, dynamic>);
  }

  Future<WorkOrderDto> completeWorkOrder(String workOrderId) async {
    final response =
        await apiClient.post(ApiConstants.completeWorkOrder(workOrderId));
    return WorkOrderDto.fromJson(response as Map<String, dynamic>);
  }
}

