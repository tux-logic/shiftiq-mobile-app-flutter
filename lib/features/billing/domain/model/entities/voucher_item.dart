enum VoucherItemType {
  service('SERVICIO', 'Mano de Obra / Servicio'),
  sparePart('REPUESTO', 'Repuesto / Autoparte');

  final String code;
  final String label;

  const VoucherItemType(this.code, this.label);

  static VoucherItemType fromCode(String code) {
    if (code.toUpperCase() == 'REPUESTO') return VoucherItemType.sparePart;
    return VoucherItemType.service;
  }
}

class VoucherItem {
  final String id;
  final String description;
  final VoucherItemType itemType;
  final int quantity;
  final double unitPrice; // Precio de venta unitario
  final double totalPrice; // unitPrice * quantity

  const VoucherItem({
    required this.id,
    required this.description,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory VoucherItem.create({
    required String id,
    required String description,
    required VoucherItemType itemType,
    required int quantity,
    required double unitPrice,
  }) {
    return VoucherItem(
      id: id,
      description: description,
      itemType: itemType,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: quantity * unitPrice,
    );
  }

  VoucherItem copyWith({
    String? id,
    String? description,
    VoucherItemType? itemType,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return VoucherItem(
      id: id ?? this.id,
      description: description ?? this.description,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
