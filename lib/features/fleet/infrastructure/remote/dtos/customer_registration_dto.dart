import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/entities/customer_registration.dart';

class CustomerRegistrationDto {
  final String id;
  final String branchId;
  final String customerId;
  final String? customerName;
  final String? phone;
  final String? email;
  final String? vehiclePlate;
  final String? vehicleModel;
  final String status;
  final DateTime? createdAt;

  CustomerRegistrationDto({
    required this.id,
    required this.branchId,
    required this.customerId,
    this.customerName,
    this.phone,
    this.email,
    this.vehiclePlate,
    this.vehicleModel,
    required this.status,
    this.createdAt,
  });

  factory CustomerRegistrationDto.fromJson(Map<String, dynamic> json) {
    return CustomerRegistrationDto(
      id: json['id'] as String? ?? json['registrationId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  CustomerRegistration toDomain() {
    return CustomerRegistration(
      id: id,
      branchId: branchId,
      customerId: customerId,
      customerName: customerName ?? 'Cliente Afiliado',
      phone: phone ?? '',
      email: email ?? '',
      vehiclePlate: vehiclePlate ?? 'S/P',
      vehicleModel: vehicleModel ?? 'Vehículo',
      status: status,
      registeredAt: createdAt,
    );
  }
}

