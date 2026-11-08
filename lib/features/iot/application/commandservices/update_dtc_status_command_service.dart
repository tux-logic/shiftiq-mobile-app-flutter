import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/aggregates/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/telemetry_repository.dart';

class UpdateDtcStatusCommandService {
  final TelemetryRepository telemetryRepository;

  const UpdateDtcStatusCommandService({
    required this.telemetryRepository,
  });

  Future<DtcAlert> execute({
    required String alertId,
    required DtcStatus status,
  }) async {
    if (alertId.trim().isEmpty) {
      throw ArgumentError('El ID de alerta DTC es obligatorio.');
    }
    return telemetryRepository.updateDtcStatus(
      id: alertId,
      status: status,
    );
  }
}
