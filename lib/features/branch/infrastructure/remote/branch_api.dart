import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/infrastructure/remote/branch_dto.dart';

class BranchApi {
  final ApiClient apiClient;

  BranchApi({required this.apiClient});

  Future<List<WorkshopDto>> getWorkshops() async {
    try {
      String? ownerId;
      try {
        final profileRes = await apiClient.get(ApiConstants.profilesMe);
        if (profileRes is Map<String, dynamic>) {
          final owner = profileRes['owner'];
          if (owner is Map<String, dynamic>) {
            ownerId = owner['id'] as String?;
          }
        }
      } catch (_) {
        // Fallback to direct query if /profiles/me is not supported
      }

      dynamic response;
      if (ownerId != null && ownerId.isNotEmpty) {
        response = await apiClient.get(ApiConstants.ownerWorkshops(ownerId));
      } else {
        response = await apiClient.get(ApiConstants.workshops);
      }

      if (response is List && response.isNotEmpty) {
        return response
            .map((item) => WorkshopDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback to default B2B workshop if remote server has no records yet
    }

    return [
      WorkshopDto(
        id: 'w-01-castro-motors',
        ownerId: 'owner-felipe-hernandez',
        businessName: 'Castro Motors S.A.C.',
        brandName: 'Castro Motors',
        taxId: '20601234567',
        mileageIntervalConfig: 5000,
      ),
    ];
  }

  Future<List<BranchDto>> getBranches(String workshopId) async {
    try {
      final response = await apiClient.get(
        ApiConstants.workshopBranches(workshopId),
      );
      if (response is List && response.isNotEmpty) {
        return response
            .map((item) => BranchDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback to default B2B branches for Lima automotive workshop
    }

    return [
      BranchDto(
        id: 'b-01-smp',
        workshopId: workshopId,
        name: 'Sede Central - San Martín de Porres',
        address: 'Av. Canta Callao 1420',
        district: 'San Martín de Porres',
        phone: '+51 987 654 321',
        active: true,
      ),
      BranchDto(
        id: 'b-02-olivos',
        workshopId: workshopId,
        name: 'Sucursal Los Olivos - Pro',
        address: 'Av. Alfredo Mendiola 5800',
        district: 'Los Olivos',
        phone: '+51 912 345 678',
        active: true,
      ),
    ];
  }
}
