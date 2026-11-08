import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/appointment_repository.dart';

class CreateAppointmentCommand {
  final String branchId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleId;
  final String vehiclePlate;
  final String vehicleModel;
  final DateTime scheduledStart;
  final String serviceType;
  final String? notes;
  final int bayNumber;

  const CreateAppointmentCommand({
    required this.branchId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.scheduledStart,
    required this.serviceType,
    this.notes,
    this.bayNumber = 1,
  });
}

class CreateAppointmentCommandService {
  final AppointmentRepository appointmentRepository;

  const CreateAppointmentCommandService({
    required this.appointmentRepository,
  });

  Future<Appointment> execute(CreateAppointmentCommand command) async {
    if (command.branchId.isEmpty) {
      throw ArgumentError('La sede (branchId) es obligatoria.');
    }
    if (command.customerName.trim().isEmpty) {
      throw ArgumentError('El nombre del cliente no puede estar vacío.');
    }
    if (command.vehiclePlate.trim().isEmpty) {
      throw ArgumentError('La placa del vehículo es obligatoria.');
    }

    return appointmentRepository.createAppointment(
      branchId: command.branchId,
      customerId: command.customerId,
      customerName: command.customerName.trim(),
      customerPhone: command.customerPhone.trim(),
      vehicleId: command.vehicleId,
      vehiclePlate: command.vehiclePlate.trim().toUpperCase(),
      vehicleModel: command.vehicleModel.trim(),
      scheduledStart: command.scheduledStart,
      serviceType: command.serviceType.trim(),
      notes: command.notes?.trim() ?? '',
      bayNumber: command.bayNumber,
    );
  }
}
