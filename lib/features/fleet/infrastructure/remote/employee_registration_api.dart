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
    final response = await apiClient.post(
      ApiConstants.employeeRegistrationRequestJoin,
      body: {
        'employeeId': employeeId,
        'branchId': branchId,
        if (speciality != null) 'speciality': speciality,
        if (specialityName != null) 'specialityName': specialityName,
        if (salary != null) 'salary': salary,
      },
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

  /// POST /api/v1/employee-registrations/{id}/reject - Reject pending application.
  Future<void> rejectRegistration(String id) async {
    await apiClient.post(
      ApiConstants.employeeRegistrationReject(id),
      body: {},
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
    return [];
  }
}
