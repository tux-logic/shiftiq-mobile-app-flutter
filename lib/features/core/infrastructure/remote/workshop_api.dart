import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP API client for automotive workshops and specialties catalog.
class WorkshopApi {
  final ApiClient apiClient;

  WorkshopApi({required this.apiClient});

  /// POST /api/v1/workshops - Create a new workshop linked to an owner.
  Future<Map<String, dynamic>> createWorkshop({
    required String ownerId,
    required String businessName,
    required String brandName,
    required String taxId,
    int mileageIntervalConfig = 5000,
  }) async {
    final response = await apiClient.post(
      ApiConstants.workshops,
      body: {
        'ownerId': ownerId,
        'businessName': businessName,
        'brandName': brandName,
        'taxId': taxId,
        'mileageIntervalConfig': mileageIntervalConfig,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/workshops/{workshopId} - Update workshop business details.
  Future<Map<String, dynamic>> updateWorkshop({
    required String workshopId,
    required String businessName,
    required String brandName,
    required String taxId,
    required int mileageIntervalConfig,
  }) async {
    final response = await apiClient.put(
      ApiConstants.workshopById(workshopId),
      body: {
        'businessName': businessName,
        'brandName': brandName,
        'taxId': taxId,
        'mileageIntervalConfig': mileageIntervalConfig,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/workshops/{workshopId} - Get workshop details by ID.
  Future<Map<String, dynamic>> getWorkshopById(String workshopId) async {
    final response = await apiClient.get(
      ApiConstants.workshopById(workshopId),
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/workshops?ownerId={ownerId} - List workshops for an owner.
  Future<List<Map<String, dynamic>>> getWorkshops({String? ownerId}) async {
    final endpoint = ownerId != null && ownerId.isNotEmpty
        ? ApiConstants.ownerWorkshops(ownerId)
        : ApiConstants.workshops;

    final response = await apiClient.get(endpoint);
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// POST /api/v1/workshops/{workshopId}/specialties - Add technical specialty.
  Future<Map<String, dynamic>> createSpecialty({
    required String workshopId,
    required String name,
    required String code,
    String? description,
  }) async {
    final response = await apiClient.post(
      ApiConstants.workshopSpecialties(workshopId),
      body: {
        'name': name,
        'code': code.toUpperCase(),
        if (description != null) 'description': description,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/workshops/{workshopId}/specialties - List workshop specialties.
  Future<List<Map<String, dynamic>>> getSpecialties({
    required String workshopId,
    bool activeOnly = true,
  }) async {
    final endpoint =
        '${ApiConstants.workshopSpecialties(workshopId)}?activeOnly=$activeOnly';
    final response = await apiClient.get(endpoint);
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// GET /api/v1/workshops/{workshopId}/specialties/{specialtyId}
  Future<Map<String, dynamic>> getSpecialtyById({
    required String workshopId,
    required String specialtyId,
  }) async {
    final response = await apiClient.get(
      ApiConstants.workshopSpecialtyById(workshopId, specialtyId),
    );
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/workshops/{workshopId}/specialties/{specialtyId}
  Future<Map<String, dynamic>> updateSpecialty({
    required String workshopId,
    required String specialtyId,
    required String name,
    String? description,
  }) async {
    final response = await apiClient.put(
      ApiConstants.workshopSpecialtyById(workshopId, specialtyId),
      body: {
        'name': name,
        if (description != null) 'description': description,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/workshops/{workshopId}/specialties/{specialtyId}
  Future<void> deactivateSpecialty({
    required String workshopId,
    required String specialtyId,
  }) async {
    await apiClient.delete(
      ApiConstants.workshopSpecialtyById(workshopId, specialtyId),
    );
  }

  /// GET /api/v1/workshops/{workshopId}/specialties/{specialtyId}/history
  Future<List<Map<String, dynamic>>> getSpecialtyHistory({
    required String workshopId,
    required String specialtyId,
  }) async {
    final response = await apiClient.get(
      ApiConstants.workshopSpecialtyHistory(workshopId, specialtyId),
    );
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
