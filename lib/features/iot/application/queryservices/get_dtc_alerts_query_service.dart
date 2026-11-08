import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/aggregates/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_severity.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/telemetry_repository.dart';

class GetDtcAlertsQueryService {
  final TelemetryRepository telemetryRepository;

  const GetDtcAlertsQueryService({
    required this.telemetryRepository,
  });

  Future<List<DtcAlert>> execute({
    required String branchId,
    DtcSeverity? severity,
    DtcStatus? status,
  }) async {
    return telemetryRepository.getDtcAlerts(
      branchId: branchId,
      severity: severity,
      status: status,
    );
  }
}
