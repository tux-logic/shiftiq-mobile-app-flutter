import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP client consuming the Vehicles endpoints of the IoT Bounded Context.
class VehicleApi {
  final ApiClient apiClient;

  const VehicleApi({required this.apiClient});

  /// POST /api/v1/vehicles
  /// Registers a motor vehicle.
  Future<Map<String, dynamic>> createVehicle({
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
    String? photoUrl,
    String? customerId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.vehicles,
      body: {
        'plateNumber': plateNumber,
        'brand': brand,
        'model': model,
        'year': year,
        'vin': vin,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (customerId != null) 'customerId': customerId,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/vehicles?branchId={branchId}&status=available-for-linking
  Future<List<dynamic>> getBranchVehiclesAvailableForLinking(
    String branchId,
  ) async {
    final response = await apiClient.get(
      ApiConstants.branchVehicles(branchId, status: 'available-for-linking'),
    );
    return response as List<dynamic>;
  }

  /// GET /api/v1/vehicles/{id}
  Future<Map<String, dynamic>> getVehicleById(String id) async {
    final response = await apiClient.get(ApiConstants.vehicleById(id));
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/vehicles/{id}
  Future<Map<String, dynamic>> updateVehicle({
    required String id,
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
    String? photoUrl,
  }) async {
    final response = await apiClient.put(
      ApiConstants.vehicleById(id),
      body: {
        'plateNumber': plateNumber,
        'brand': brand,
        'model': model,
        'year': year,
        'vin': vin,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/vehicles/{id}
  Future<void> deleteVehicle(String id) async {
    await apiClient.delete(ApiConstants.vehicleById(id));
  }

  /// GET /api/v1/vehicles/{vehicleId}/telemetry-snapshots
  Future<List<dynamic>> getVehicleTelemetrySnapshots({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.vehicleTelemetrySnapshots(vehicleId)}?page=$page&size=$size',
    );
    return response as List<dynamic>;
  }

  /// GET /api/v1/vehicles/{vehicleId}/dtc-alerts
  Future<List<dynamic>> getVehicleDtcAlerts({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.vehicleDtcAlerts(vehicleId)}?page=$page&size=$size',
    );
    return response as List<dynamic>;
  }

  /// GET /api/v1/customers/{customerId}/vehicles
  Future<List<dynamic>> getCustomerVehicles(String customerId) async {
    final response = await apiClient.get(
      ApiConstants.customerVehicles(customerId),
    );
    return response as List<dynamic>;
  }
}
