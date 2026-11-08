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

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
