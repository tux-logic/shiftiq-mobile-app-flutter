enum VoucherStatus {
  draft('BORRADOR', 'Borrador'),
  issued('EMITIDO', 'Emitido a SUNAT'),
  paid('PAGADO', 'Cobrado y Cancelado'),
  cancelled('ANULADO', 'Anulado con Comunicación de Baja');

  final String code;
  final String label;

  const VoucherStatus(this.code, this.label);

  static VoucherStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'EMITIDO':
        return VoucherStatus.issued;
      case 'PAGADO':
        return VoucherStatus.paid;
      case 'ANULADO':
        return VoucherStatus.cancelled;
      case 'BORRADOR':
      default:
        return VoucherStatus.draft;
    }
  }
}
