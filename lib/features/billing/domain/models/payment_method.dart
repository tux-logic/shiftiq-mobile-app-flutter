enum PaymentMethod {
  cash('CASH', 'Efectivo en Caja'),
  creditCard('CREDIT_CARD', 'Tarjeta de Crédito'),
  debitCard('DEBIT_CARD', 'Tarjeta de Débito'),
  bankTransfer('BANK_TRANSFER', 'Transferencia Bancaria');

  final String code;
  final String label;

  const PaymentMethod(this.code, this.label);

  // Backward compatibility getters
  static PaymentMethod get posCard => PaymentMethod.creditCard;
  static PaymentMethod get yapePlin => PaymentMethod.bankTransfer;

  static PaymentMethod fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'CREDIT_CARD':
      case 'TARJETA_CREDITO':
      case 'CARD':
      case 'TARJETA_POS':
        return PaymentMethod.creditCard;
      case 'DEBIT_CARD':
      case 'TARJETA_DEBITO':
        return PaymentMethod.debitCard;
      case 'BANK_TRANSFER':
      case 'TRANSFERENCIA':
      case 'TRANSFER':
      case 'YAPE_PLIN':
        return PaymentMethod.bankTransfer;
      case 'CASH':
      case 'EFECTIVO':
      default:
        return PaymentMethod.cash;
    }
  }
}
