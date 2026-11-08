import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/dtos/dtc_alert_dto.dart';

class TelemetryApi {
  final ApiClient apiClient;

  TelemetryApi({required this.apiClient});

  Future<List<DtcAlertDto>> getDtcAlerts({
    required String branchId,
    String? severity,
    String? status,
  }) async {
    var url = '/api/v1/telemetry/dtc-alerts?branchId=$branchId';
    if (severity != null && severity.isNotEmpty) {
      url += '&severity=$severity';
    }
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    final response = await apiClient.get(url);
    if (response is List) {
      return response
          .map((item) => DtcAlertDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<DtcAlertDto> getDtcAlertById(String id) async {
    final response = await apiClient.get('/api/v1/telemetry/dtc-alerts/$id');
    return DtcAlertDto.fromJson(response as Map<String, dynamic>);
  }

  Future<DtcAlertDto> updateDtcStatus({
    required String id,
    required String status,
  }) async {
    final response = await apiClient.put(
      '/api/v1/telemetry/dtc-alerts/$id',
      body: {'status': status},
    );
    return DtcAlertDto.fromJson(response as Map<String, dynamic>);
  }
}
