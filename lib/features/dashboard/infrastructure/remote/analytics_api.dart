import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/infrastructure/remote/analytics_dto.dart';

class AnalyticsApi {
  final ApiClient apiClient;

  AnalyticsApi({required this.apiClient});

  Future<BranchSummaryDto> getBranchSummary(String branchId) async {
    final response = await apiClient.get(
      ApiConstants.branchAnalyticsSummary(branchId),
    );
    return BranchSummaryDto.fromJson(response as Map<String, dynamic>);
  }
}

