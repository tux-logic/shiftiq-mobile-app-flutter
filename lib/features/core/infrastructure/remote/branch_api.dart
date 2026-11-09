import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP API client for physical workshop branches and branch subscriptions.
class BranchApi {
  final ApiClient apiClient;

  BranchApi({required this.apiClient});

  /// POST /api/v1/branches - Create a new branch under a workshop.
  Future<Map<String, dynamic>> createBranch({
    required String workshopId,
    required String code,
    required String name,
    required String address,
    String? phone,
  }) async {
    final response = await apiClient.post(
      ApiConstants.branches,
      body: {
        'workshopId': workshopId,
        'code': code,
        'name': name,
        'address': address,
        if (phone != null) 'phone': phone,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/branches/{branchId} - Update branch details.
  Future<Map<String, dynamic>> updateBranch({
    required String branchId,
    required String code,
    required String name,
    required String address,
    String? phone,
  }) async {
    final response = await apiClient.put(
      ApiConstants.branchById(branchId),
      body: {
        'code': code,
        'name': name,
        'address': address,
        if (phone != null) 'phone': phone,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/branches/{branchId} - Get branch details by ID.
  Future<Map<String, dynamic>> getBranchById(String branchId) async {
    final response = await apiClient.get(
      ApiConstants.branchById(branchId),
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/branches?workshopId={workshopId} - List branches for a workshop.
  Future<List<Map<String, dynamic>>> getBranches(String workshopId) async {
    final response = await apiClient.get(
      ApiConstants.workshopBranches(workshopId),
    );
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// POST /api/v1/branches/{branchId}/subscriptions - Assign subscription to branch.
  Future<Map<String, dynamic>> assignSubscription({
    required String branchId,
    required String planId,
    required String billingCycle,
    required String cardNumber,
    required String cardHolderName,
    required String expirationDate,
    required String cvv,
  }) async {
    final response = await apiClient.post(
      ApiConstants.branchSubscriptions(branchId),
      body: {
        'planId': planId,
        'billingCycle': billingCycle,
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expirationDate': expirationDate,
        'cvv': cvv,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/branches/{branchId}/subscription - Cancel active subscription.
  Future<void> cancelSubscription(String branchId) async {
    await apiClient.delete(
      ApiConstants.branchSubscription(branchId),
    );
  }
}
