import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/telemetry_repository.dart';

class GetLiveSensorStreamQueryService {
  final TelemetryRepository telemetryRepository;

  const GetLiveSensorStreamQueryService({
    required this.telemetryRepository,
  });

  Future<List<LiveSensorReading>> execute(String vehicleId) async {
    return telemetryRepository.getLiveSensorReadings(vehicleId);
  }
}
