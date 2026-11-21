import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/dtos/dtc_alert_dto.dart';

/// Remote HTTP client consuming DTC alert endpoints conforming to documented contracts:
/// - GET /api/v1/vehicles/{vehicleId}/dtc-alerts
/// - GET /api/v1/obd2-device-registrations/{id}/dtc-alerts
class TelemetryApi {
  final ApiClient apiClient;

  TelemetryApi({required this.apiClient});

  /// GET /api/v1/vehicles/{vehicleId}/dtc-alerts
  Future<List<DtcAlertDto>> getVehicleDtcAlerts({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.vehicleDtcAlerts(vehicleId)}?page=$page&size=$size',
    );
    if (response is List) {
      return response
          .map((item) => DtcAlertDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/obd2-device-registrations/{id}/dtc-alerts
  Future<List<DtcAlertDto>> getRegistrationDtcAlerts({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.obd2DeviceRegistrationDtcAlerts(registrationId)}?page=$page&size=$size',
    );
    if (response is List) {
      return response
          .map((item) => DtcAlertDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
