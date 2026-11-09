/// Lifecycle status for a workshop work order.
enum WorkOrderStatus {
  pending('PENDING', 'Pendiente'),
  inProgress('IN_PROGRESS', 'En Proceso'),
  completed('COMPLETED', 'Completada'),
  paid('PAID', 'Pagada / Facturada'),
  deleted('DELETED', 'Cancelada');

  final String value;
  final String label;

  const WorkOrderStatus(this.value, this.label);

  static WorkOrderStatus fromString(String? val) {
    if (val == null) return WorkOrderStatus.pending;
    return WorkOrderStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => WorkOrderStatus.pending,
    );
  }
}
