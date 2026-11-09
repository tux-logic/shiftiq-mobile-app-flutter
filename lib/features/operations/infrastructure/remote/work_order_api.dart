import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP client consuming the Work Orders endpoints of the Operations Bounded Context.
class WorkOrderApi {
  final ApiClient apiClient;

  const WorkOrderApi({required this.apiClient});

  /// POST /api/v1/work-orders
  /// Opens a work order from a scheduled appointment.
  Future<Map<String, dynamic>> createWorkOrder({
    required String appointmentId,
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    List<String> entryInspectionImages = const [],
  }) async {
    final response = await apiClient.post(
      ApiConstants.workOrders,
      body: {
        'appointmentId': appointmentId,
        'branchId': branchId,
        'vehicleId': vehicleId,
        'customerId': customerId,
        'diagnosticSummary': diagnosticSummary,
        'mileageIn': mileageIn,
        'entryInspectionImages': entryInspectionImages,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/work-orders?branchId={branchId} OR ?vehicleId={vehicleId}
  Future<List<dynamic>> getWorkOrders({
    String? branchId,
    String? vehicleId,
  }) async {
    var query = '';
    if (branchId != null && branchId.isNotEmpty) {
      query = '?branchId=$branchId';
    } else if (vehicleId != null && vehicleId.isNotEmpty) {
      query = '?vehicleId=$vehicleId';
    } else {
      throw ArgumentError('Either branchId or vehicleId must be provided to query work orders.');
    }

    final response = await apiClient.get('${ApiConstants.workOrders}$query');
    return response as List<dynamic>;
  }

  /// GET /api/v1/work-orders/{id}
  Future<Map<String, dynamic>> getWorkOrderById(String id) async {
    final response = await apiClient.get(ApiConstants.workOrderById(id));
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/work-orders/{id}
  Future<Map<String, dynamic>> updateWorkOrderIntake({
    required String id,
    required String diagnosticSummary,
    required int mileageIn,
    List<String>? entryInspectionImages,
  }) async {
    final response = await apiClient.put(
      ApiConstants.workOrderById(id),
      body: {
        'diagnosticSummary': diagnosticSummary,
        'mileageIn': mileageIn,
        'entryInspectionImages': ?entryInspectionImages,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/work-orders/{id}/complete
  Future<Map<String, dynamic>> completeWorkOrder(String id) async {
    final response = await apiClient.post(ApiConstants.workOrderComplete(id));
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/work-orders/{id}
  Future<void> deleteWorkOrder(String id) async {
    await apiClient.delete(ApiConstants.workOrderById(id));
  }
}
