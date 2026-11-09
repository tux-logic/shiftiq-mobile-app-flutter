/// Entity representing the operational link between a Customer profile and a Branch.
class CustomerRegistration {
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

  const CustomerRegistration({
    required this.id,
    required this.branchId,
    required this.customerId,
    required this.customerName,
    required this.phone,
    this.email = '',
    required this.vehiclePlate,
    required this.vehicleModel,
    this.status = 'ACTIVE',
    this.registeredAt,
  });

  CustomerRegistration copyWith({
    String? id,
    String? branchId,
    String? customerId,
    String? customerName,
    String? phone,
    String? email,
    String? vehiclePlate,
    String? vehicleModel,
    String? status,
    DateTime? registeredAt,
  }) {
    return CustomerRegistration(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
