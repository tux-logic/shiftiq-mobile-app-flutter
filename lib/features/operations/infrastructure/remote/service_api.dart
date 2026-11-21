import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP client consuming the Services Catalog endpoints of the Operations Bounded Context.
class ServiceApi {
  final ApiClient apiClient;

  const ServiceApi({required this.apiClient});

  /// POST /api/v1/services
  Future<Map<String, dynamic>> createService({
    required String branchId,
    required String name,
    required double price,
  }) async {
    final response = await apiClient.post(
      ApiConstants.services,
      body: {
        'branchId': branchId,
        'name': name,
        'price': price,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/services?branchId={branchId}
  Future<List<dynamic>> getBranchServices(String branchId) async {
    final response = await apiClient.get(ApiConstants.branchServices(branchId));
    return response as List<dynamic>;
  }

  /// PUT /api/v1/services/{serviceId}
  Future<Map<String, dynamic>> updateService({
    required String serviceId,
    required String name,
    required double price,
  }) async {
    final response = await apiClient.put(
      ApiConstants.serviceById(serviceId),
      body: {
        'name': name,
        'price': price,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/services/{serviceId}
  Future<void> deleteService(String serviceId) async {
    await apiClient.delete(ApiConstants.serviceById(serviceId));
  }
}
