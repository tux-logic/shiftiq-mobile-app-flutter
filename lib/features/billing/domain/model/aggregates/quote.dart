import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';

enum QuoteStatus {
  draft('BORRADOR', 'Borrador'),
  sent('ENVIADO', 'Enviado al Cliente por WhatsApp/Email'),
  approved('APROBADO', 'Aprobado por el Cliente'),
  rejected('RECHAZADO', 'Rechazado'),
  converted('CONVERTIDO', 'Convertido a Orden de Trabajo');

  final String code;
  final String label;

  const QuoteStatus(this.code, this.label);

  static QuoteStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'ENVIADO':
        return QuoteStatus.sent;
      case 'APROBADO':
        return QuoteStatus.approved;
      case 'RECHAZADO':
        return QuoteStatus.rejected;
      case 'CONVERTIDO':
        return QuoteStatus.converted;
      case 'BORRADOR':
      default:
        return QuoteStatus.draft;
    }
  }
}

class Quote {
  final String id;
  final String branchId;
  final String? workOrderId;
  final String quoteNumber; // COT-2026-0042
  final String customerName;
  final String customerPhone;
  final String vehiclePlate;
  final String vehicleModel;
  final List<VoucherItem> items;
  final double subtotal;
  final double igv;
  final double total;
  final DateTime validUntil;
  final QuoteStatus status;
  final DateTime createdAt;

  const Quote({
    required this.id,
    required this.branchId,
    this.workOrderId,
    required this.quoteNumber,
    required this.customerName,
    required this.customerPhone,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.items,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.validUntil,
    required this.status,
    required this.createdAt,
  });

  factory Quote.calculateAndCreate({
    required String id,
    required String branchId,
    String? workOrderId,
    required String quoteNumber,
    required String customerName,
    required String customerPhone,
    required String vehiclePlate,
    required String vehicleModel,
    required List<VoucherItem> items,
    required DateTime validUntil,
    QuoteStatus status = QuoteStatus.draft,
    DateTime? createdAt,
  }) {
    final double totalCalculated =
        items.fold(0.0, (acc, item) => acc + item.totalPrice);
    final double subtotalCalculated =
        double.parse((totalCalculated / 1.18).toStringAsFixed(2));
    final double igvCalculated =
        double.parse((totalCalculated - subtotalCalculated).toStringAsFixed(2));

    return Quote(
      id: id,
      branchId: branchId,
      workOrderId: workOrderId,
      quoteNumber: quoteNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      items: items,
      subtotal: subtotalCalculated,
      igv: igvCalculated,
      total: totalCalculated,
      validUntil: validUntil,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  Quote copyWith({
    String? id,
    String? branchId,
    String? workOrderId,
    String? quoteNumber,
    String? customerName,
    String? customerPhone,
    String? vehiclePlate,
    String? vehicleModel,
    List<VoucherItem>? items,
    double? subtotal,
    double? igv,
    double? total,
    DateTime? validUntil,
    QuoteStatus? status,
    DateTime? createdAt,
  }) {
    return Quote(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      workOrderId: workOrderId ?? this.workOrderId,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      igv: igv ?? this.igv,
      total: total ?? this.total,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
