import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';

class Appointment {
  final String id;
  final String branchId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleId;
  final String vehiclePlate;
  final String vehicleModel;
  final DateTime scheduledStart;
  final String serviceType;
  final String notes;
  final AppointmentStatus status;
  final int bayNumber;
  final DateTime? createdAt;

  const Appointment({
    required this.id,
    required this.branchId,
    required this.customerId,
    this.customerName = 'Cliente del Taller',
    this.customerPhone = '',
    required this.vehicleId,
    this.vehiclePlate = 'S/P',
    this.vehicleModel = 'Vehículo General',
    required this.scheduledStart,
    this.serviceType = 'Mantenimiento General',
    this.notes = '',
    required this.status,
    this.bayNumber = 1,
    this.createdAt,
  });

  bool get isPending => status == AppointmentStatus.pending;
  bool get isConfirmed => status == AppointmentStatus.confirmed;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCanceled => status == AppointmentStatus.canceled;

  String get formattedTime {
    final hour = scheduledStart.hour;
    final minute = scheduledStart.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$formattedHour:$minute $period';
  }

  String get formattedDate {
    final day = scheduledStart.day.toString().padLeft(2, '0');
    final month = scheduledStart.month.toString().padLeft(2, '0');
    final year = scheduledStart.year;
    return '$day/$month/$year';
  }

  String get formattedBay => 'Bahía $bayNumber';

  Appointment copyWith({
    String? id,
    String? branchId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? vehicleId,
    String? vehiclePlate,
    String? vehicleModel,
    DateTime? scheduledStart,
    String? serviceType,
    String? notes,
    AppointmentStatus? status,
    int? bayNumber,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      vehicleId: vehicleId ?? this.vehicleId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      serviceType: serviceType ?? this.serviceType,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      bayNumber: bayNumber ?? this.bayNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
