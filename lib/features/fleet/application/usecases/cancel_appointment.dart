import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case canceling a scheduled workshop appointment.
class CancelAppointmentUseCase {
  final FleetRepository repository;

  CancelAppointmentUseCase({required this.repository});

  Future<void> execute(String id) {
    return repository.cancelAppointment(id);
  }
}
