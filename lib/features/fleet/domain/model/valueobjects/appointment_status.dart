/// Value Object representing the lifecycle status of a workshop appointment.
enum AppointmentStatus {
  pending('PENDING', 'Pendiente'),
  confirmed('PENDING', 'Confirmada'),
  completed('COMPLETED', 'Atendida'),
  canceled('CANCELED', 'Cancelada');

  final String value;
  final String label;

  const AppointmentStatus(this.value, this.label);

  static AppointmentStatus fromString(String? value) {
    if (value == null) return AppointmentStatus.pending;
    final normalized = value.trim().toUpperCase();
    if (normalized == 'CANCELLED' || normalized == 'CANCELED') {
      return AppointmentStatus.canceled;
    }
    if (normalized == 'COMPLETED' || normalized == 'ATENDIDA') {
      return AppointmentStatus.completed;
    }
    return AppointmentStatus.pending;
  }
}
