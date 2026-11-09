enum VoucherStatus {
  pending('PENDING', 'Pendiente'),
  emitted('EMITTED', 'Emitido a SUNAT'),
  partiallyPaid('PARTIALLY_PAID', 'Pago Parcial'),
  paid('PAID', 'Pagado'),
  canceled('CANCELED', 'Anulado'),
  emissionFailed('EMISSION_FAILED', 'Error de Emisión');

  final String code;
  final String label;

  const VoucherStatus(this.code, this.label);

  // Backward compatibility aliases
  static VoucherStatus get draft => VoucherStatus.pending;
  static VoucherStatus get issued => VoucherStatus.emitted;
  static VoucherStatus get cancelled => VoucherStatus.canceled;

  static VoucherStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'EMITTED':
      case 'EMITIDO':
      case 'ISSUED':
        return VoucherStatus.emitted;
      case 'PARTIALLY_PAID':
      case 'PAGO_PARCIAL':
        return VoucherStatus.partiallyPaid;
      case 'PAID':
      case 'PAGADO':
        return VoucherStatus.paid;
      case 'CANCELED':
      case 'CANCELLED':
      case 'ANULADO':
        return VoucherStatus.canceled;
      case 'EMISSION_FAILED':
      case 'ERROR_EMISION':
        return VoucherStatus.emissionFailed;
      case 'PENDING':
      case 'BORRADOR':
      case 'DRAFT':
      default:
        return VoucherStatus.pending;
    }
  }
}
