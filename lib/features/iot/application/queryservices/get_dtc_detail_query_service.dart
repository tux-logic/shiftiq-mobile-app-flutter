import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/aggregates/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/telemetry_repository.dart';

class GetDtcDetailQueryService {
  final TelemetryRepository telemetryRepository;

  const GetDtcDetailQueryService({
    required this.telemetryRepository,
  });

  Future<DtcAlert> execute(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('El ID de alerta DTC no puede estar vacío.');
    }
    return telemetryRepository.getDtcAlertById(id);
  }
}
