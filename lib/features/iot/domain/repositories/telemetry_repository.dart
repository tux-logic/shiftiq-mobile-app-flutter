import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/aggregates/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_severity.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';

abstract class TelemetryRepository {
  Future<List<DtcAlert>> getDtcAlerts({
    required String branchId,
    DtcSeverity? severity,
    DtcStatus? status,
  });

  Future<DtcAlert> getDtcAlertById(String id);

  Future<DtcAlert> updateDtcStatus({
    required String id,
    required DtcStatus status,
  });

  Future<List<LiveSensorReading>> getLiveSensorReadings(String vehicleId);
}
