enum PaymentMethod {
  cash('EFECTIVO', 'Efectivo en Caja'),
  yapePlin('YAPE_PLIN', 'Billetera Digital (Yape / Plin)'),
  posCard('TARJETA_POS', 'Tarjeta Débito / Crédito (POS)'),
  bankTransfer('TRANSFERENCIA', 'Transferencia Bancaria BCP/BBVA');

  final String code;
  final String label;

  const PaymentMethod(this.code, this.label);

  static PaymentMethod fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'YAPE_PLIN':
        return PaymentMethod.yapePlin;
      case 'TARJETA_POS':
      case 'CARD':
        return PaymentMethod.posCard;
      case 'TRANSFERENCIA':
      case 'TRANSFER':
        return PaymentMethod.bankTransfer;
      case 'EFECTIVO':
      case 'CASH':
      default:
        return PaymentMethod.cash;
    }
  }
}
