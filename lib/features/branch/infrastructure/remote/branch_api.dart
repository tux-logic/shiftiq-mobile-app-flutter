import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/infrastructure/remote/branch_dto.dart';

class BranchApi {
  final ApiClient apiClient;

  BranchApi({required this.apiClient});

  Future<List<WorkshopDto>> getWorkshops() async {
    final response = await apiClient.get(ApiConstants.workshops);
    if (response is List) {
      return response
          .map((item) => WorkshopDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<BranchDto>> getBranches(String workshopId) async {
    final response = await apiClient.get(ApiConstants.workshopBranches(workshopId));
    if (response is List) {
      return response
          .map((item) => BranchDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
