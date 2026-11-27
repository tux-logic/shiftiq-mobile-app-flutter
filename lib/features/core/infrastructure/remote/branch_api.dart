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
    String? coverImageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'workshopId': workshopId,
      'code': code,
      'name': name,
      'address': address,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (coverImageUrl != null && coverImageUrl.isNotEmpty) {
      body['coverImageUrl'] = coverImageUrl;
    }
    if (latitude != null && longitude != null) {
      body['latitude'] = latitude;
      body['longitude'] = longitude;
    }

    final response = await apiClient.post(
      ApiConstants.branches,
      body: body,
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
    String? coverImageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'code': code,
      'name': name,
      'address': address,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (coverImageUrl != null && coverImageUrl.isNotEmpty) {
      body['coverImageUrl'] = coverImageUrl;
    }
    if (latitude != null && longitude != null) {
      body['latitude'] = latitude;
      body['longitude'] = longitude;
    }

    final response = await apiClient.put(
      ApiConstants.branchById(branchId),
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/branches/catalog - List active branches scoped to customer workshops.
  Future<List<Map<String, dynamic>>> getBranchCatalog() async {
    final response = await apiClient.get(
      ApiConstants.branchesCatalog,
    );
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
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

  /// GET /api/v1/branches/{branchId}/operating-hours
  Future<List<Map<String, dynamic>>> getBranchOperatingHours(
    String branchId,
  ) async {
    final response =
        await apiClient.get(ApiConstants.branchOperatingHours(branchId));
    if (response is List) return response.cast<Map<String, dynamic>>();
    return [];
  }

  /// PUT /api/v1/branches/{branchId}/operating-hours
  Future<List<Map<String, dynamic>>> updateBranchOperatingHours(
    String branchId,
    List<Map<String, dynamic>> days,
  ) async {
    final response = await apiClient.put(
      ApiConstants.branchOperatingHours(branchId),
      body: {'days': days},
    );
    if (response is List) return response.cast<Map<String, dynamic>>();
    return [];
  }

  /// DELETE /api/v1/branches/{branchId}/operating-hours
  Future<void> deleteBranchOperatingHours(String branchId) async {
    await apiClient.delete(ApiConstants.branchOperatingHours(branchId));
  }

  /// GET /api/v1/branches/{branchId}/operating-hours/exceptions
  Future<List<Map<String, dynamic>>> getBranchOperatingHoursExceptions(
    String branchId,
  ) async {
    final response = await apiClient
        .get(ApiConstants.branchOperatingHoursExceptions(branchId));
    if (response is List) return response.cast<Map<String, dynamic>>();
    return [];
  }

  /// POST /api/v1/branches/{branchId}/operating-hours/exceptions
  Future<Map<String, dynamic>> createBranchOperatingHoursException({
    required String branchId,
    required String date,
    required bool open,
    String? openTime,
    String? closeTime,
    String? reason,
  }) async {
    final response = await apiClient.post(
      ApiConstants.branchOperatingHoursExceptions(branchId),
      body: {
        'date': date,
        'open': open,
        'openTime': open ? openTime : null,
        'closeTime': open ? closeTime : null,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/branches/{branchId}/operating-hours/exceptions/{exceptionId}
  Future<void> deleteBranchOperatingHoursException(
    String branchId,
    String exceptionId,
  ) async {
    await apiClient.delete(
      ApiConstants.branchOperatingHoursExceptionById(branchId, exceptionId),
    );
  }

  /// GET /api/v1/workshops/{workshopId}/operating-hours
  Future<List<Map<String, dynamic>>> getWorkshopOperatingHours(
    String workshopId,
  ) async {
    final response =
        await apiClient.get(ApiConstants.workshopOperatingHours(workshopId));
    if (response is List) return response.cast<Map<String, dynamic>>();
    return [];
  }

  /// PUT /api/v1/workshops/{workshopId}/operating-hours
  Future<List<Map<String, dynamic>>> updateWorkshopOperatingHours(
    String workshopId,
    List<Map<String, dynamic>> days,
  ) async {
    final response = await apiClient.put(
      ApiConstants.workshopOperatingHours(workshopId),
      body: {'days': days},
    );
    if (response is List) return response.cast<Map<String, dynamic>>();
    return [];
  }

  /// GET /api/v1/workshops/{workshopId}/operating-hours/exceptions
  Future<List<Map<String, dynamic>>> getWorkshopOperatingHoursExceptions(
    String workshopId,
  ) async {
    final response = await apiClient
        .get(ApiConstants.workshopOperatingHoursExceptions(workshopId));
    if (response is List) return response.cast<Map<String, dynamic>>();
    return [];
  }

  /// POST /api/v1/workshops/{workshopId}/operating-hours/exceptions
  Future<Map<String, dynamic>> createWorkshopOperatingHoursException({
    required String workshopId,
    required String date,
    required bool open,
    String? openTime,
    String? closeTime,
    String? reason,
  }) async {
    final response = await apiClient.post(
      ApiConstants.workshopOperatingHoursExceptions(workshopId),
      body: {
        'date': date,
        'open': open,
        'openTime': open ? openTime : null,
        'closeTime': open ? closeTime : null,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/workshops/{workshopId}/operating-hours/exceptions/{exceptionId}
  Future<void> deleteWorkshopOperatingHoursException(
    String workshopId,
    String exceptionId,
  ) async {
    await apiClient.delete(
      ApiConstants.workshopOperatingHoursExceptionById(workshopId, exceptionId),
    );
  }
}
