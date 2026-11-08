class TaxDocument {
  final String type; // DNI, RUC, CE
  final String number;

  const TaxDocument({
    required this.type,
    required this.number,
  });

  bool get isValid {
    final clean = number.trim();
    if (type == 'DNI') {
      return RegExp(r'^\d{8}$').hasMatch(clean);
    } else if (type == 'RUC') {
      return RegExp(r'^(10|20)\d{9}$').hasMatch(clean);
    }
    return clean.isNotEmpty;
  }

  String? validate() {
    final clean = number.trim();
    if (clean.isEmpty) {
      return 'El número de documento es obligatorio';
    }
    if (type == 'DNI') {
      if (!RegExp(r'^\d{8}$').hasMatch(clean)) {
        return 'El DNI debe contener exactamente 8 dígitos numéricos';
      }
    } else if (type == 'RUC') {
      if (!RegExp(r'^(10|20)\d{9}$').hasMatch(clean)) {
        return 'El RUC debe tener 11 dígitos y empezar con 10 o 20';
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxDocument &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          number == other.number;

  @override
  int get hashCode => type.hashCode ^ number.hashCode;
}
