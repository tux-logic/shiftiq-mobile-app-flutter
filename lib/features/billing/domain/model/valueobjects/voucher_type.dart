enum VoucherType {
  boleta('BOLETA', 'Boleta de Venta Electrónica', 'B001'),
  factura('FACTURA', 'Factura Electrónica', 'F001'),
  notaVenta('NOTA_VENTA', 'Nota de Venta Interna', 'NV01');

  final String code;
  final String label;
  final String defaultSeries;

  const VoucherType(this.code, this.label, this.defaultSeries);

  bool get requiresRuc => this == VoucherType.factura;

  static VoucherType fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'FACTURA':
        return VoucherType.factura;
      case 'NOTA_VENTA':
        return VoucherType.notaVenta;
      case 'BOLETA':
      default:
        return VoucherType.boleta;
    }
  }
}
