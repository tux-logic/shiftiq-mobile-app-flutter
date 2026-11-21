/// Aggregate root representing the active link between an OBD-II scanner and a vehicle.
class Obd2DeviceRegistration {
  final String id;
  final String obd2DeviceId;
  final String branchId;
  final String vehicleId;
  final String status;
  final DateTime createdAt;

  const Obd2DeviceRegistration({
    required this.id,
    required this.obd2DeviceId,
    required this.branchId,
    required this.vehicleId,
    this.status = 'ACTIVE',
    required this.createdAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isInactive => status.toUpperCase() == 'INACTIVE';

  Obd2DeviceRegistration copyWith({
    String? id,
    String? obd2DeviceId,
    String? branchId,
    String? vehicleId,
    String? status,
    DateTime? createdAt,
  }) {
    return Obd2DeviceRegistration(
      id: id ?? this.id,
      obd2DeviceId: obd2DeviceId ?? this.obd2DeviceId,
      branchId: branchId ?? this.branchId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
