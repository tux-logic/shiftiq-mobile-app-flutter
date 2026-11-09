import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP client consuming the Analytics Bounded Context endpoints.
class AnalyticsApi {
  final ApiClient apiClient;

  const AnalyticsApi({required this.apiClient});

  /// GET /api/v1/analytics/branches/{branchId}/summary
  /// Returns daily operational snapshot for an authorized branch.
  Future<Map<String, dynamic>> getBranchSummary(String branchId) async {
    final response = await apiClient.get(
      ApiConstants.branchAnalyticsSummary(branchId),
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/analytics/branches/{branchId}/financial?startDate=...&endDate=...
  /// Returns chronological financial snapshots within an optional date window (max 365 days).
  Future<List<dynamic>> getBranchFinancialAnalytics({
    required String branchId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    var path = ApiConstants.branchAnalyticsFinancial(branchId);
    if (queryParams.isNotEmpty) {
      final query = Uri(queryParameters: queryParams).query;
      path = '$path?$query';
    }

    final response = await apiClient.get(path);
    return response as List<dynamic>;
  }

  /// GET /api/v1/analytics/network/summary
  /// Returns multi-branch executive overview for Owners and Platform Admins.
  Future<Map<String, dynamic>> getNetworkSummary() async {
    final response = await apiClient.get(
      ApiConstants.networkAnalyticsSummary,
    );
    return response as Map<String, dynamic>;
  }
}
