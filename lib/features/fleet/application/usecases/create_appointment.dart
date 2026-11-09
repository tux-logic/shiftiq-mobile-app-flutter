import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case orchestrating workshop appointment scheduling.
class CreateAppointmentUseCase {
  final FleetRepository repository;

  CreateAppointmentUseCase({required this.repository});

  Future<Appointment> execute({
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    DateTime? scheduledEnd,
    String notes = '',
    String serviceType = 'Mantenimiento General',
    String customerName = 'Cliente del Taller',
    String customerPhone = '',
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    int bayNumber = 1,
  }) {
    return repository.createAppointment(
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      notes: notes,
      serviceType: serviceType,
      customerName: customerName,
      customerPhone: customerPhone,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      bayNumber: bayNumber,
    );
  }
}

/// Backward compatibility alias.
typedef CreateAppointmentCommandService = CreateAppointmentUseCase;
