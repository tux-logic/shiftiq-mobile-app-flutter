enum DtcStatus {
  active('ACTIVE', 'Activo / No Resuelto'),
  inInspection('IN_INSPECTION', 'En Diagnóstico'),
  resolved('RESOLVED', 'Resuelto / Borrado');

  final String value;
  final String label;

  const DtcStatus(this.value, this.label);

  static DtcStatus fromString(String? val) {
    if (val == null) return DtcStatus.active;
    return DtcStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => DtcStatus.active,
    );
  }
}
