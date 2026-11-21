class MercadoPagoPreference {
  final String preferenceId;
  final String initPoint;
  final String sandboxInitPoint;
  final double amount;
  final String currency;
  final String externalReference;

  const MercadoPagoPreference({
    required this.preferenceId,
    required this.initPoint,
    required this.sandboxInitPoint,
    required this.amount,
    required this.currency,
    required this.externalReference,
  });

  MercadoPagoPreference copyWith({
    String? preferenceId,
    String? initPoint,
    String? sandboxInitPoint,
    double? amount,
    String? currency,
    String? externalReference,
  }) {
    return MercadoPagoPreference(
      preferenceId: preferenceId ?? this.preferenceId,
      initPoint: initPoint ?? this.initPoint,
      sandboxInitPoint: sandboxInitPoint ?? this.sandboxInitPoint,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      externalReference: externalReference ?? this.externalReference,
    );
  }
}
