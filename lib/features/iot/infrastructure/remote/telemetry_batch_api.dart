import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote HTTP client for ingesting bulk vehicular telemetry batches.
class TelemetryBatchApi {
  final ApiClient apiClient;

  const TelemetryBatchApi({required this.apiClient});

  /// POST /api/v1/telemetry-batches
  Future<Map<String, dynamic>> ingestBatch({
    required String obd2DeviceId,
    required List<Map<String, dynamic>> snapshots,
  }) async {
    final response = await apiClient.post(
      ApiConstants.telemetryBatches,
      body: {
        'obd2DeviceId': obd2DeviceId,
        'snapshots': snapshots,
      },
    );
    return response as Map<String, dynamic>;
  }
}
