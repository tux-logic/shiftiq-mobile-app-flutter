import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP client consuming OBD2 Device hardware endpoints.
class Obd2DeviceApi {
  final ApiClient apiClient;

  const Obd2DeviceApi({required this.apiClient});

  /// POST /api/v1/obd2-devices
  Future<Map<String, dynamic>> createDevice({
    required String branchId,
    required String macAddress,
  }) async {
    final response = await apiClient.post(
      ApiConstants.obd2Devices,
      body: {
        'branchId': branchId,
        'macAddress': macAddress,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/obd2-devices?branchId={branchId}&status={status}
  Future<List<dynamic>> getDevices({
    required String branchId,
    String? status,
  }) async {
    final response = await apiClient.get(
      ApiConstants.branchObd2Devices(branchId, status: status),
    );
    return response as List<dynamic>;
  }

  /// GET /api/v1/obd2-devices/{id}
  Future<Map<String, dynamic>> getDeviceById(String id) async {
    final response = await apiClient.get(ApiConstants.obd2DeviceById(id));
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/obd2-devices/{id}
  Future<Map<String, dynamic>> updateDevice({
    required String id,
    required String macAddress,
  }) async {
    final response = await apiClient.put(
      ApiConstants.obd2DeviceById(id),
      body: {
        'macAddress': macAddress,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/obd2-devices/{id}
  Future<void> deleteDevice(String id) async {
    await apiClient.delete(ApiConstants.obd2DeviceById(id));
  }

  /// GET /api/v1/obd2-devices/{deviceId}/telemetry-snapshots/latest
  Future<Map<String, dynamic>> getLatestTelemetrySnapshot(
    String deviceId,
  ) async {
    final response = await apiClient.get(
      ApiConstants.obd2DeviceLatestTelemetry(deviceId),
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/obd2-devices/{deviceId}/telemetry-snapshots
  Future<List<dynamic>> getDeviceTelemetrySnapshots({
    required String deviceId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.obd2DeviceTelemetry(deviceId)}?page=$page&size=$size',
    );
    return response as List<dynamic>;
  }
}
