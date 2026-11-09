import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';

/// Remote HTTP API client for unified profiles, role discovery, and document search.
class ProfileApi {
  final ApiClient apiClient;

  ProfileApi({required this.apiClient});

  /// GET /api/v1/profiles/me - Returns unified profile context for authenticated caller.
  Future<Map<String, dynamic>> getMyProfileContext() async {
    final response = await apiClient.get(ApiConstants.profilesMe);
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/profiles/roles?userId={userId} - Returns active core roles for user.
  Future<List<String>> getProfileRoles(String userId) async {
    final response = await apiClient.get(ApiConstants.profileRoles(userId));
    if (response is List) {
      return response.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// GET /api/v1/profiles?documentNumber={documentNumber} - Lookup by DNI/RUC.
  Future<Map<String, dynamic>?> lookupProfileByDocument(
    String documentNumber,
  ) async {
    try {
      final response = await apiClient.get(
        ApiConstants.profileByDocument(documentNumber),
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } on NotFoundException {
      return null;
    }
  }

  /// POST /api/v1/owners - Create owner profile linked to IAM user.
  Future<Map<String, dynamic>> createOwnerProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String documentType,
    required String documentNumber,
    required String phone,
  }) async {
    final response = await apiClient.post(
      ApiConstants.owners,
      body: {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'documentType': documentType,
        'documentNumber': documentNumber,
        'phone': phone,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/owners?userId={userId}
  Future<Map<String, dynamic>?> getOwnerByUserId(String userId) async {
    final response = await apiClient.get(ApiConstants.ownerByUserId(userId));
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is List && response.isNotEmpty) {
      return response.first as Map<String, dynamic>;
    }
    return null;
  }

  /// GET /api/v1/owners/{ownerId}
  Future<Map<String, dynamic>> getOwnerById(String ownerId) async {
    final response = await apiClient.get(ApiConstants.ownerById(ownerId));
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/owners/{ownerId}
  Future<Map<String, dynamic>> updateOwnerProfile({
    required String ownerId,
    required String firstName,
    required String lastName,
    required String documentType,
    required String documentNumber,
    required String phone,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'phone': phone,
    };

    final response = await apiClient.put(
      ApiConstants.ownerById(ownerId),
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/owners/{ownerId}
  Future<void> deleteOwnerProfile(String ownerId) async {
    await apiClient.delete(ApiConstants.ownerById(ownerId));
  }

  /// POST /api/v1/employees - Create employee profile linked to IAM user.
  Future<Map<String, dynamic>> createEmployeeProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String documentType,
    required String documentNumber,
    required String phone,
  }) async {
    final response = await apiClient.post(
      ApiConstants.employees,
      body: {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'documentType': documentType,
        'documentNumber': documentNumber,
        'phone': phone,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/employees?userId={userId}
  Future<Map<String, dynamic>?> getEmployeeByUserId(String userId) async {
    final response = await apiClient.get(ApiConstants.employeeByUserId(userId));
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is List && response.isNotEmpty) {
      return response.first as Map<String, dynamic>;
    }
    return null;
  }

  /// GET /api/v1/employees/{employeeId}
  Future<Map<String, dynamic>> getEmployeeById(String employeeId) async {
    final response = await apiClient.get(ApiConstants.employeeById(employeeId));
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/employees?documentNumber={documentNumber}
  Future<List<Map<String, dynamic>>> getEmployeesByDocumentNumber(
    String documentNumber,
  ) async {
    final response = await apiClient.get(
      ApiConstants.employeeByDocument(documentNumber),
    );
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    if (response is Map<String, dynamic>) {
      return [response];
    }
    return [];
  }

  /// PUT /api/v1/employees/{employeeId}
  Future<Map<String, dynamic>> updateEmployeeProfile({
    required String employeeId,
    required String firstName,
    required String lastName,
    required String documentType,
    required String documentNumber,
    required String phone,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'phone': phone,
    };

    final response = await apiClient.put(
      ApiConstants.employeeById(employeeId),
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/employees/{employeeId}
  Future<void> deleteEmployeeProfile(String employeeId) async {
    await apiClient.delete(ApiConstants.employeeById(employeeId));
  }

  /// POST /api/v1/customers - Create customer profile linked to IAM user.
  Future<Map<String, dynamic>> createCustomerProfile({
    required String userId,
    required String firstName,
    required String lastName,
    String? businessName,
    required String documentType,
    required String documentNumber,
    required String phone,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'phone': phone,
    };
    if (businessName != null) body['businessName'] = businessName;

    final response = await apiClient.post(
      ApiConstants.customers,
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/customers?userId={userId}
  Future<Map<String, dynamic>?> getCustomerByUserId(String userId) async {
    final response = await apiClient.get(ApiConstants.customerByUserId(userId));
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is List && response.isNotEmpty) {
      return response.first as Map<String, dynamic>;
    }
    return null;
  }

  /// GET /api/v1/customers/{customerId}
  Future<Map<String, dynamic>> getCustomerById(String customerId) async {
    final response = await apiClient.get(ApiConstants.customerById(customerId));
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/customers/{customerId}
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String customerId,
    required String documentType,
    required String documentNumber,
    required String phone,
    String? firstName,
    String? lastName,
    String? businessName,
  }) async {
    final body = <String, dynamic>{
      'documentType': documentType,
      'documentNumber': documentNumber,
      'phone': phone,
    };
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (businessName != null) body['businessName'] = businessName;

    final response = await apiClient.put(
      ApiConstants.customerById(customerId),
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/customers/{customerId}
  Future<void> deleteCustomerProfile(String customerId) async {
    await apiClient.delete(ApiConstants.customerById(customerId));
  }
}
