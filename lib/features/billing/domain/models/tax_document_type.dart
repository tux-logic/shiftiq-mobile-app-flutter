enum TaxDocumentType {
  dni('DNI', 'Documento Nacional de Identidad', 8),
  ruc('RUC', 'Registro Único de Contribuyentes', 11);

  final String code;
  final String label;
  final int requiredLength;

  const TaxDocumentType(this.code, this.label, this.requiredLength);

  static TaxDocumentType fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'RUC':
        return TaxDocumentType.ruc;
      case 'DNI':
      default:
        return TaxDocumentType.dni;
    }
  }

  bool isValid(String documentNumber) {
    final clean = documentNumber.trim();
    if (this == TaxDocumentType.dni) {
      return RegExp(r'^\d{8}$').hasMatch(clean);
    } else if (this == TaxDocumentType.ruc) {
      return RegExp(r'^(10|20)\d{9}$').hasMatch(clean);
    }
    return false;
  }
}

class TaxDocument {
  final dynamic type; // TaxDocumentType or String
  final String number;

  const TaxDocument({
    required this.type,
    required this.number,
  });

  TaxDocumentType get documentType {
    if (type is TaxDocumentType) return type as TaxDocumentType;
    return TaxDocumentType.fromCode(type.toString());
  }

  bool get isValid => documentType.isValid(number);

  String? validate() {
    final clean = number.trim();
    if (clean.isEmpty) {
      return 'Customer document number is required';
    }
    if (documentType == TaxDocumentType.dni) {
      if (!RegExp(r'^\d{8}$').hasMatch(clean)) {
        return 'El DNI debe contener exactamente 8 dígitos numéricos';
      }
    } else if (documentType == TaxDocumentType.ruc) {
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
