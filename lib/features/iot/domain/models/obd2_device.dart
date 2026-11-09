/// Operating status of a physical OBD-II dongle.
enum Obd2DeviceStatus {
  available('AVAILABLE'),
  linked('LINKED'),
  deleted('DELETED');

  final String value;
  const Obd2DeviceStatus(this.value);

  static Obd2DeviceStatus fromString(String status) {
    return switch (status.toUpperCase()) {
      'LINKED' => Obd2DeviceStatus.linked,
      'DELETED' => Obd2DeviceStatus.deleted,
      _ => Obd2DeviceStatus.available,
    };
  }
}

/// Entity representing a physical OBD-II scanner hardware device in a branch.
class Obd2Device {
  final String id;
  final String branchId;
  final String macAddress;
  final Obd2DeviceStatus status;

  const Obd2Device({
    required this.id,
    required this.branchId,
    required this.macAddress,
    this.status = Obd2DeviceStatus.available,
  });

  bool get isAvailable => status == Obd2DeviceStatus.available;
  bool get isLinked => status == Obd2DeviceStatus.linked;

  Obd2Device copyWith({
    String? id,
    String? branchId,
    String? macAddress,
    Obd2DeviceStatus? status,
  }) {
    return Obd2Device(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      macAddress: macAddress ?? this.macAddress,
      status: status ?? this.status,
    );
  }
}
