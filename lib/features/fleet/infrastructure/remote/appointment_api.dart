import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP API client for automotive workshop appointments in Fleet context.
class AppointmentApi {
  final ApiClient apiClient;

  AppointmentApi({required this.apiClient});

  /// POST /api/v1/appointments - Schedule new appointment.
  Future<Map<String, dynamic>> createAppointment({
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    DateTime? scheduledEnd,
    String? notes,
    String? serviceType,
  }) async {
    final response = await apiClient.post(
      ApiConstants.appointments,
      body: {
        'branchId': branchId,
        'customerId': customerId,
        'vehicleId': vehicleId,
        'scheduledStart': scheduledStart.toIso8601String(),
        if (scheduledEnd != null) 'scheduledEnd': scheduledEnd.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (serviceType != null && serviceType.isNotEmpty)
          'serviceType': serviceType,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/appointments - List appointments with multi-criteria filtering.
  Future<List<Map<String, dynamic>>> getAppointments({
    String? branchId,
    String? status,
    String? customerId,
    String? vehicleId,
  }) async {
    final queryParams = <String, String>{};
    if (branchId != null && branchId.isNotEmpty) {
      queryParams['branchId'] = branchId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status.toUpperCase();
    }
    if (customerId != null && customerId.isNotEmpty) {
      queryParams['customerId'] = customerId;
    }
    if (vehicleId != null && vehicleId.isNotEmpty) {
      queryParams['vehicleId'] = vehicleId;
    }

    final uri = Uri(path: ApiConstants.appointments, queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await apiClient.get(uri.toString());

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// GET /api/v1/appointments/{id} - Get appointment detail.
  Future<Map<String, dynamic>> getAppointmentById(String id) async {
    final response = await apiClient.get(ApiConstants.appointmentById(id));
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/appointments/{id} - Update full appointment resource.
  Future<Map<String, dynamic>> updateAppointment({
    required String id,
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    required String status,
    String? notes,
  }) async {
    final response = await apiClient.put(
      ApiConstants.appointmentById(id),
      body: {
        'branchId': branchId,
        'customerId': customerId,
        'vehicleId': vehicleId,
        'scheduledStart': scheduledStart.toIso8601String(),
        'status': status.toUpperCase(),
        if (notes != null) 'notes': notes,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/appointments/{id} - Cancel appointment.
  Future<void> cancelAppointment(String id) async {
    await apiClient.delete(ApiConstants.appointmentById(id));
  }

  /// PUT /api/v1/appointments/{id}/status - Fast status update.
  Future<Map<String, dynamic>> updateAppointmentStatus({
    required String id,
    required String status,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.appointmentStatus(id),
        body: {'status': status.toUpperCase()},
      );
      return response as Map<String, dynamic>;
    } catch (_) {
      // Fallback to updating status via direct put
      final current = await getAppointmentById(id);
      return updateAppointment(
        id: id,
        branchId: current['branchId']?.toString() ?? '',
        customerId: current['customerId']?.toString() ?? '',
        vehicleId: current['vehicleId']?.toString() ?? '',
        scheduledStart: DateTime.tryParse(current['scheduledStart']?.toString() ?? '') ?? DateTime.now(),
        status: status,
        notes: current['notes']?.toString(),
      );
    }
  }
}
