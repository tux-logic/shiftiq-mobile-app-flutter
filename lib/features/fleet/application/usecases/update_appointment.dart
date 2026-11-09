import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case updating scheduled appointment details and operational status.
class UpdateAppointmentUseCase {
  final FleetRepository repository;

  UpdateAppointmentUseCase({
    FleetRepository? repository,
    FleetRepository? appointmentRepository,
  }) : repository = (repository ?? appointmentRepository)!;

  Future<Appointment> execute({
    String? id,
    String? appointmentId,
    String? branchId,
    String? customerId,
    String? vehicleId,
    DateTime? scheduledStart,
    AppointmentStatus? status,
    AppointmentStatus? newStatus,
    String? notes,
  }) {
    final effectiveId = id ?? appointmentId;
    if (effectiveId == null || effectiveId.trim().isEmpty) {
      throw ArgumentError('El ID de la cita es obligatorio.');
    }

    final effectiveStatus = status ?? newStatus;

    if (branchId == null &&
        customerId == null &&
        vehicleId == null &&
        scheduledStart == null) {
      if (effectiveStatus == null) {
        throw ArgumentError('El estado de la cita es obligatorio.');
      }
      return repository.updateAppointmentStatus(
        id: effectiveId,
        status: effectiveStatus,
      );
    }

    return repository.updateAppointment(
      id: effectiveId,
      branchId: branchId ?? '',
      customerId: customerId ?? '',
      vehicleId: vehicleId ?? '',
      scheduledStart: scheduledStart ?? DateTime.now(),
      status: effectiveStatus ?? AppointmentStatus.pending,
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
