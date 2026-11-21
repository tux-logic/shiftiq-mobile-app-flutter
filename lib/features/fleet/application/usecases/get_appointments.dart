import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case retrieving workshop appointments with multi-criteria filtering.
class GetAppointmentsUseCase {
  final FleetRepository repository;

  GetAppointmentsUseCase({
    FleetRepository? repository,
    FleetRepository? appointmentRepository,
  }) : repository = (repository ?? appointmentRepository)!;

  Future<List<Appointment>> execute({
    String? branchId,
    AppointmentStatus? status,
    String? customerId,
    String? vehicleId,
    DateTime? date,
  }) {
    return repository.getAppointments(
      branchId: branchId,
      status: status,
      customerId: customerId,
      vehicleId: vehicleId,
      date: date,
    );
  }

  Future<Appointment> getById(String id) {
    return repository.getAppointmentById(id);
  }
}

/// Backward compatibility alias.
typedef GetAppointmentsByBranchQueryService = GetAppointmentsUseCase;
