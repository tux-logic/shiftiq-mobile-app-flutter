import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP client consuming OBD2 Device-to-Vehicle registration endpoints.
class Obd2RegistrationApi {
  final ApiClient apiClient;

  const Obd2RegistrationApi({required this.apiClient});

  /// POST /api/v1/obd2-device-registrations
  /// Pairs an available scanner to a vehicle in a branch.
  Future<Map<String, dynamic>> linkDeviceToVehicle({
    required String obd2DeviceId,
    required String branchId,
    required String vehicleId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.obd2DeviceRegistrations,
      body: {
        'obd2DeviceId': obd2DeviceId,
        'branchId': branchId,
        'vehicleId': vehicleId,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// PATCH /api/v1/obd2-device-registrations/{id}
  /// Transitions registration status (e.g. ACTIVE -> INACTIVE to unpair scanner).
  Future<Map<String, dynamic>> updateRegistrationStatus({
    required String registrationId,
    required String status,
  }) async {
    final response = await apiClient.patch(
      ApiConstants.obd2DeviceRegistrationById(registrationId),
      body: {
        'status': status.toUpperCase(),
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/obd2-device-registrations?branchId={branchId}&status={status}
  Future<List<dynamic>> getRegistrations({
    required String branchId,
    String status = 'ACTIVE',
  }) async {
    final response = await apiClient.get(
      ApiConstants.branchObd2DeviceRegistrations(branchId, status: status),
    );
    return response as List<dynamic>;
  }

  /// GET /api/v1/obd2-device-registrations/{id}/telemetry-snapshots
  Future<List<dynamic>> getRegistrationTelemetrySnapshots({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.obd2DeviceRegistrationTelemetry(registrationId)}?page=$page&size=$size',
    );
    return response as List<dynamic>;
  }

  /// GET /api/v1/obd2-device-registrations/{id}/dtc-alerts
  Future<List<dynamic>> getRegistrationDtcAlerts({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.obd2DeviceRegistrationDtcAlerts(registrationId)}?page=$page&size=$size',
    );
    return response as List<dynamic>;
  }
}
