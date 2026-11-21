import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP API client for staff onboarding, applications, and approvals.
class EmployeeRegistrationApi {
  final ApiClient apiClient;

  EmployeeRegistrationApi({required this.apiClient});

  /// POST /api/v1/employee-registrations - Hierarchical staff onboarding.
  Future<Map<String, dynamic>> onboardEmployee({
    required String employeeId,
    required String branchId,
    required String speciality,
    required String specialityName,
    required double salary,
    String role = 'ROLE_EMPLOYEE',
  }) async {
    final response = await apiClient.post(
      ApiConstants.employeeRegistrations,
      body: {
        'employeeId': employeeId,
        'branchId': branchId,
        'speciality': speciality,
        'specialityName': specialityName,
        'salary': salary,
        'role': role,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/employee-registrations/request-join - Mechanic applies to branch.
  Future<Map<String, dynamic>> requestJoinBranch({
    required String employeeId,
    required String branchId,
    String? speciality,
    String? specialityName,
    double? salary,
  }) async {
    final body = <String, dynamic>{
      'employeeId': employeeId,
      'branchId': branchId,
    };
    if (speciality != null) body['speciality'] = speciality;
    if (specialityName != null) body['specialityName'] = specialityName;
    if (salary != null) body['salary'] = salary;

    final response = await apiClient.post(
      ApiConstants.employeeRegistrationRequestJoin,
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/employee-registrations/{id}/approve - Approve pending mechanic.
  Future<Map<String, dynamic>> approveRegistration(String id) async {
    final response = await apiClient.post(
      ApiConstants.employeeRegistrationApprove(id),
      body: {},
    );
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/employee-registrations/{id}/reject - Reject pending application with optional audit reason.
  Future<void> rejectRegistration(String id, {String? reason}) async {
    final body = <String, dynamic>{};
    if (reason != null && reason.trim().isNotEmpty) {
      body['reason'] = reason.trim();
    }
    await apiClient.post(
      ApiConstants.employeeRegistrationReject(id),
      body: body,
    );
  }

  /// GET /api/v1/employee-registrations - List registrations with optional filters.
  Future<List<Map<String, dynamic>>> getEmployeeRegistrations({
    String? branchId,
    String? status,
    String? employeeId,
  }) async {
    final queryParams = <String, String>{};
    if (branchId != null && branchId.isNotEmpty) {
      queryParams['branchId'] = branchId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status.toUpperCase();
    }
    if (employeeId != null && employeeId.isNotEmpty) {
      queryParams['employeeId'] = employeeId;
    }

    final uri = Uri(
      path: ApiConstants.employeeRegistrations,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final response = await apiClient.get(uri.toString());

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    if (response is Map<String, dynamic>) {
      return [response];
    }
    return [];
  }

  /// GET /api/v1/employee-registrations/{id} - Get single employee registration by ID.
  Future<Map<String, dynamic>> getEmployeeRegistrationById(String id) async {
    final response = await apiClient.get(
      ApiConstants.employeeRegistrationById(id),
    );
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/employee-registrations/{id} - Update contract specialty and salary terms.
  Future<Map<String, dynamic>> updateEmployeeRegistration({
    required String id,
    required String speciality,
    required String specialityName,
    required double salary,
  }) async {
    final body = <String, dynamic>{
      'speciality': speciality,
      'specialityName': specialityName,
      'salary': salary,
    };

    final response = await apiClient.put(
      ApiConstants.employeeRegistrationById(id),
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/employee-registrations/{id} - Soft delete / dismiss staff member.
  Future<void> deleteEmployeeRegistration(String id) async {
    await apiClient.delete(
      ApiConstants.employeeRegistrationById(id),
    );
  }

  /// GET /api/v1/branches/{branchId}/employees/{employeeId}/history - Staff career history.
  Future<List<Map<String, dynamic>>> getEmployeeCareerHistory({
    required String branchId,
    required String employeeId,
  }) async {
    final response = await apiClient.get(
      ApiConstants.branchEmployeeHistory(branchId, employeeId),
    );
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    if (response is Map<String, dynamic>) {
      return [response];
    }
    return [];
  }
}
