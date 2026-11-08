import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';

class AppointmentDto {
  final String id;
  final String branchId;
  final String customerId;
  final String vehicleId;
  final DateTime scheduledStart;
  final String? serviceType;
  final String? notes;
  final String status;
  final DateTime? createdAt;

  AppointmentDto({
    required this.id,
    required this.branchId,
    required this.customerId,
    required this.vehicleId,
    required this.scheduledStart,
    this.serviceType,
    this.notes,
    required this.status,
    this.createdAt,
  });

  factory AppointmentDto.fromJson(Map<String, dynamic> json) {
    return AppointmentDto(
      id: json['id'] as String? ?? json['appointmentId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart'].toString())
          : DateTime.now(),
      serviceType: json['serviceType'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Appointment toDomain({
    String customerName = 'Cliente del Taller',
    String customerPhone = '',
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    int bayNumber = 1,
  }) {
    return Appointment(
      id: id,
      branchId: branchId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      vehicleId: vehicleId,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      scheduledStart: scheduledStart,
      serviceType: serviceType ?? 'Mantenimiento General',
      notes: notes ?? '',
      status: AppointmentStatus.fromString(status),
      bayNumber: bayNumber,
      createdAt: createdAt,
    );
  }
}

