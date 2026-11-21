/// Operational status for an individual repair task inside a work order.
enum TaskStatus {
  pending('PENDING', 'Pendiente'),
  doing('DOING', 'En Ejecución'),
  completed('COMPLETED', 'Completada');

  final String value;
  final String label;

  const TaskStatus(this.value, this.label);

  static TaskStatus fromString(String? val) {
    if (val == null) return TaskStatus.pending;
    return TaskStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => TaskStatus.pending,
    );
  }
}
