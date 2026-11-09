import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';

/// DTO for Appointment resource with Dart 3 pattern-matching validation.
class AppointmentDto {
  final String id;
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
  final String notes;
  final String status;
  final int bayNumber;
  final DateTime? createdAt;

  AppointmentDto({
    required this.id,
    required this.branchId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.scheduledStart,
    this.scheduledEnd,
    required this.serviceType,
    required this.notes,
    required this.status,
    required this.bayNumber,
    this.createdAt,
  });

  factory AppointmentDto.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String id,
          'branchId': final String branchId,
          'customerId': final String customerId,
          'vehicleId': final String vehicleId,
          'scheduledStart': final String startStr,
        }) {
      final start = DateTime.tryParse(startStr) ?? DateTime.now();
      final end = json['scheduledEnd'] != null
          ? DateTime.tryParse(json['scheduledEnd'].toString())
          : null;
      final created = json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null;

      return AppointmentDto(
        id: id,
        branchId: branchId,
        customerId: customerId,
        customerName: json['customerName']?.toString() ?? 'Cliente del Taller',
        customerPhone: json['customerPhone']?.toString() ?? '',
        vehicleId: vehicleId,
        vehiclePlate: json['vehiclePlate']?.toString() ?? 'S/P',
        vehicleModel: json['vehicleModel']?.toString() ?? 'Vehículo General',
        scheduledStart: start,
        scheduledEnd: end,
        serviceType:
            json['serviceType']?.toString() ?? 'Mantenimiento General',
        notes: json['notes']?.toString() ?? '',
        status: json['status']?.toString() ?? 'PENDING',
        bayNumber: (json['bayNumber'] as num?)?.toInt() ?? 1,
        createdAt: created,
      );
    }
    throw const FormatException('Invalid or missing fields in AppointmentDto JSON');
  }

  Appointment toDomain() {
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
      scheduledEnd: scheduledEnd,
      serviceType: serviceType,
      notes: notes,
      status: AppointmentStatus.fromString(status),
      bayNumber: bayNumber,
      createdAt: createdAt,
    );
  }
}

/// DTO for CustomerRegistration resource with pattern-matching validation.
class CustomerRegistrationDto {
  final String id;
  final String branchId;
  final String customerId;
  final String customerName;
  final String phone;
  final String email;
  final String vehiclePlate;
  final String vehicleModel;
  final String status;
  final DateTime? registeredAt;

  CustomerRegistrationDto({
    required this.id,
    required this.branchId,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.status,
    this.registeredAt,
  });

  factory CustomerRegistrationDto.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String id,
          'branchId': final String branchId,
          'customerId': final String customerId,
        }) {
      final regAt = json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['registeredAt'] != null
              ? DateTime.tryParse(json['registeredAt'].toString())
              : null);

      return CustomerRegistrationDto(
        id: id,
        branchId: branchId,
        customerId: customerId,
        customerName: json['customerName']?.toString() ?? 'Cliente Registrado',
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        vehiclePlate: json['vehiclePlate']?.toString() ?? 'S/P',
        vehicleModel: json['vehicleModel']?.toString() ?? 'Vehículo',
        status: json['status']?.toString() ?? 'ACTIVE',
        registeredAt: regAt,
      );
    }
    throw const FormatException(
      'Invalid or missing fields in CustomerRegistrationDto JSON',
    );
  }

  CustomerRegistration toDomain() {
    return CustomerRegistration(
      id: id,
      branchId: branchId,
      customerId: customerId,
      customerName: customerName,
      phone: phone,
      email: email,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      status: status,
      registeredAt: registeredAt,
    );
  }
}

/// DTO for EmployeeRegistration resource with pattern-matching validation.
class EmployeeRegistrationDto {
  final String id;
  final String employeeId;
  final String branchId;
  final String speciality;
  final String specialityName;
  final double salary;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? approvedAt;

  EmployeeRegistrationDto({
    required this.id,
    required this.employeeId,
    required this.branchId,
    required this.speciality,
    required this.specialityName,
    required this.salary,
    required this.role,
    required this.status,
    this.createdAt,
    this.approvedAt,
  });

  factory EmployeeRegistrationDto.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String id,
          'employeeId': final String employeeId,
          'branchId': final String branchId,
          'speciality': final String speciality,
        }) {
      final created = json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null;
      final approved = json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null;

      return EmployeeRegistrationDto(
        id: id,
        employeeId: employeeId,
        branchId: branchId,
        speciality: speciality,
        specialityName: json['specialityName']?.toString() ?? speciality,
        salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
        role: json['role']?.toString() ?? 'ROLE_EMPLOYEE',
        status: json['status']?.toString() ?? 'ACTIVE',
        createdAt: created,
        approvedAt: approved,
      );
    }
    throw const FormatException(
      'Invalid or missing fields in EmployeeRegistrationDto JSON',
    );
  }

  EmployeeRegistration toDomain() {
    return EmployeeRegistration(
      id: id,
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
      role: role,
      status: status,
      createdAt: createdAt,
      approvedAt: approvedAt,
    );
  }
}
