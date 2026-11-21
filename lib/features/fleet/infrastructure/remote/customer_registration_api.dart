import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP API client for customer-branch affiliations in Fleet context.
class CustomerRegistrationApi {
  final ApiClient apiClient;

  CustomerRegistrationApi({required this.apiClient});

  /// POST /api/v1/customer-registrations - Register customer in branch.
  Future<Map<String, dynamic>> registerCustomerToBranch({
    required String branchId,
    required String customerId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.customerRegistrations,
      body: {
        'branchId': branchId,
        'customerId': customerId,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/customer-registrations - List registrations with optional filters.
  Future<List<Map<String, dynamic>>> getCustomerRegistrations({
    String? branchId,
    String? status,
    String? customerId,
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

    final uri = Uri(
      path: ApiConstants.customerRegistrations,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final response = await apiClient.get(uri.toString());

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// GET /api/v1/customer-registrations/{id} - Get customer registration by ID.
  Future<Map<String, dynamic>> getCustomerRegistrationById(String id) async {
    final response = await apiClient.get(
      ApiConstants.customerRegistrationById(id),
    );
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/customer-registrations/{id} - Update customer registration status.
  Future<Map<String, dynamic>> updateCustomerRegistrationStatus({
    required String id,
    required String status,
  }) async {
    final response = await apiClient.put(
      ApiConstants.customerRegistrationById(id),
      body: {
        'status': status.toUpperCase() == 'BLACKLISTED'
            ? 'INACTIVE'
            : status.toUpperCase(),
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/customer-registrations/{id} - Deactivate customer registration.
  Future<void> deleteCustomerRegistration(String id) async {
    await apiClient.delete(
      ApiConstants.customerRegistrationById(id),
    );
  }
}
