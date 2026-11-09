import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case updating scheduled appointment details and operational status.
class UpdateAppointmentUseCase {
  final FleetRepository repository;

  UpdateAppointmentUseCase({required this.repository});

  Future<Appointment> execute({
    required String id,
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    required AppointmentStatus status,
    String? notes,
  }) {
    return repository.updateAppointment(
      id: id,
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledStart: scheduledStart,
      status: status,
      notes: notes,
    );
  }

  Future<Appointment> updateStatus({
    required String id,
    required AppointmentStatus status,
  }) {
    return repository.updateAppointmentStatus(
      id: id,
      status: status,
    );
  }
}

/// Backward compatibility alias.
typedef UpdateAppointmentStatusCommandService = UpdateAppointmentUseCase;
