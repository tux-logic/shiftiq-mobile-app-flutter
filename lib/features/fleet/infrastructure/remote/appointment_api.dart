import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/dtos/appointment_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/dtos/customer_registration_dto.dart';

class AppointmentApi {
  final ApiClient apiClient;

  AppointmentApi({required this.apiClient});

  Future<List<AppointmentDto>> getAppointments({
    required String branchId,
    String? status,
  }) async {
    var url = '${ApiConstants.appointments}?branchId=$branchId';
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    final response = await apiClient.get(url);
    if (response is List) {
      return response
          .map((item) => AppointmentDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<AppointmentDto> getAppointmentById(String id) async {
    final response = await apiClient.get('${ApiConstants.appointments}/$id');
    return AppointmentDto.fromJson(response as Map<String, dynamic>);
  }

  Future<AppointmentDto> createAppointment({
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    String? serviceType,
    String? notes,
  }) async {
    final response = await apiClient.post(
      ApiConstants.appointments,
      body: {
        'branchId': branchId,
        'customerId': customerId,
        'vehicleId': vehicleId,
        'scheduledStart': scheduledStart.toIso8601String(),
        'serviceType': serviceType,
        'notes': notes,
      },
    );
    return AppointmentDto.fromJson(response as Map<String, dynamic>);
  }

  Future<AppointmentDto> updateAppointmentStatus({
    required String id,
    required String status,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.appointments}/$id',
      body: {
        'status': status,
      },
    );
    return AppointmentDto.fromJson(response as Map<String, dynamic>);
  }

  Future<List<CustomerRegistrationDto>> getCustomerRegistrations(
    String branchId,
  ) async {
    final response = await apiClient.get(
      '/api/v1/customer-registrations?branchId=$branchId',
    );
    if (response is List) {
      return response
          .map(
            (item) =>
                CustomerRegistrationDto.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }
}

