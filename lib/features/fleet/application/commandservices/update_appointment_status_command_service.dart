import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/appointment_repository.dart';

class UpdateAppointmentStatusCommandService {
  final AppointmentRepository appointmentRepository;

  const UpdateAppointmentStatusCommandService({
    required this.appointmentRepository,
  });

  Future<Appointment> execute({
    required String appointmentId,
    required AppointmentStatus newStatus,
  }) async {
    if (appointmentId.trim().isEmpty) {
      throw ArgumentError('El ID de la cita es obligatorio.');
    }
    return appointmentRepository.updateAppointmentStatus(
      id: appointmentId,
      status: newStatus,
    );
  }
}
