import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/appointment_repository.dart';

class GetAppointmentsByBranchQueryService {
  final AppointmentRepository appointmentRepository;

  const GetAppointmentsByBranchQueryService({
    required this.appointmentRepository,
  });

  Future<List<Appointment>> execute({
    required String branchId,
    DateTime? date,
    AppointmentStatus? status,
  }) async {
    return appointmentRepository.getAppointmentsByBranch(
      branchId: branchId,
      date: date,
      status: status,
    );
  }
}
