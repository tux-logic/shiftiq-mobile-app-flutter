enum VoucherType {
  receipt('RECEIPT', 'Boleta de Venta Electrónica', 'B001'),
  invoice('INVOICE', 'Factura Electrónica', 'F001'),
  salesNote('SALES_NOTE', 'Nota de Venta Interna', 'NV01');

  final String code;
  final String label;
  final String defaultSeries;

  const VoucherType(this.code, this.label, this.defaultSeries);

  bool get requiresRuc => this == VoucherType.invoice;

  // Backward compatibility getters
  static VoucherType get boleta => VoucherType.receipt;
  static VoucherType get factura => VoucherType.invoice;
  static VoucherType get notaVenta => VoucherType.salesNote;

  static VoucherType fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'INVOICE':
      case 'FACTURA':
        return VoucherType.invoice;
      case 'SALES_NOTE':
      case 'NOTA_VENTA':
        return VoucherType.salesNote;
      case 'RECEIPT':
      case 'BOLETA':
      default:
        return VoucherType.receipt;
    }
  }
}
