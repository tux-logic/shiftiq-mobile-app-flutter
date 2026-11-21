import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Legacy command object for appointment creation form in UI.
class CreateAppointmentCommand {
  final String branchId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleId;
  final String vehiclePlate;
  final String vehicleModel;
  final DateTime scheduledStart;
  final DateTime? scheduledEnd;
  final String serviceType;
  final String? notes;
  final int bayNumber;

  const CreateAppointmentCommand({
    required this.branchId,
    required this.customerId,
    this.customerName = '',
    this.customerPhone = '',
    required this.vehicleId,
    this.vehiclePlate = '',
    this.vehicleModel = '',
    required this.scheduledStart,
    this.scheduledEnd,
    this.serviceType = '',
    this.notes,
    this.bayNumber = 1,
  });
}

/// Use case orchestrating workshop appointment scheduling.
class CreateAppointmentUseCase {
  final FleetRepository repository;

  CreateAppointmentUseCase({
    FleetRepository? repository,
    FleetRepository? appointmentRepository,
  }) : repository = (repository ?? appointmentRepository)!;

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

/// Backward compatibility command service for UI forms and view models.
class CreateAppointmentCommandService {
  final FleetRepository _repository;

  CreateAppointmentCommandService({
    FleetRepository? repository,
    FleetRepository? appointmentRepository,
    CreateAppointmentUseCase? useCase,
  }) : _repository = (repository ?? appointmentRepository ?? useCase?.repository)!;

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

    return _repository.createAppointment(
      branchId: command.branchId,
      customerId: command.customerId,
      customerName: command.customerName.trim(),
      customerPhone: command.customerPhone.trim(),
      vehicleId: command.vehicleId,
      vehiclePlate: command.vehiclePlate.trim().toUpperCase(),
      vehicleModel: command.vehicleModel.trim(),
      scheduledStart: command.scheduledStart,
      scheduledEnd: command.scheduledEnd,
      serviceType: command.serviceType.trim(),
      notes: command.notes?.trim() ?? '',
      bayNumber: command.bayNumber,
    );
  }
}
