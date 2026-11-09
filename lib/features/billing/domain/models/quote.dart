import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/electronic_voucher.dart';

enum QuoteStatus {
  draft('DRAFT', 'Borrador'),
  sent('SENT', 'Enviado'),
  approved('APPROVED', 'Aprobado'),
  rejected('REJECTED', 'Rechazado'),
  converted('CONVERTED', 'Convertido'),
  canceled('CANCELED', 'Cancelado');

  final String code;
  final String label;

  const QuoteStatus(this.code, this.label);

  static QuoteStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'APPROVED':
      case 'APROBADO':
        return QuoteStatus.approved;
      case 'CANCELED':
      case 'CANCELLED':
      case 'CANCELADA':
      case 'ANULADO':
        return QuoteStatus.canceled;
      case 'SENT':
      case 'ENVIADO':
        return QuoteStatus.sent;
      case 'REJECTED':
      case 'RECHAZADO':
        return QuoteStatus.rejected;
      case 'CONVERTED':
      case 'CONVERTIDO':
        return QuoteStatus.converted;
      case 'DRAFT':
      case 'BORRADOR':
      default:
        return QuoteStatus.draft;
    }
  }
}

class QuoteItem {
  final String? id;
  final String type; // SERVICE, PRODUCT
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;

  const QuoteItem({
    this.id,
    required this.type,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory QuoteItem.create({
    String? id,
    required String type,
    required String name,
    required int quantity,
    required double unitPrice,
  }) {
    return QuoteItem(
      id: id,
      type: type,
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      total: double.parse((quantity * unitPrice).toStringAsFixed(2)),
    );
  }

  QuoteItem copyWith({
    String? id,
    String? type,
    String? name,
    int? quantity,
    double? unitPrice,
    double? total,
  }) {
    return QuoteItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
    );
  }
}

class Quote {
  final String id;
  final String branchId;
  final String? workOrderId;
  final String quoteNumber;
  final String customerName;
  final String customerPhone;
  final String vehiclePlate;
  final String vehicleModel;
  final List<dynamic> items; // QuoteItem or VoucherItem
  final double subtotalAmount;
  final double discountPercentage;
  final double totalAmount;
  final QuoteStatus status;
  final DateTime validUntil;
  final DateTime? approvedAt;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.branchId,
    this.workOrderId,
    required this.quoteNumber,
    required this.customerName,
    String? customerPhone,
    String? vehiclePlate,
    String? vehicleModel,
    this.items = const [],
    double? subtotalAmount,
    double? subtotal,
    this.discountPercentage = 0.0,
    double? totalAmount,
    double? total,
    double? igv,
    required this.status,
    DateTime? validUntil,
    this.approvedAt,
    DateTime? createdAt,
  })  : customerPhone = customerPhone ?? '',
        vehiclePlate = vehiclePlate ?? '',
        vehicleModel = vehicleModel ?? '',
        subtotalAmount = subtotalAmount ?? subtotal ?? 0.0,
        totalAmount = totalAmount ?? total ?? 0.0,
        validUntil = validUntil ?? DateTime.now().add(const Duration(days: 7)),
        createdAt = createdAt ?? DateTime.now();

  // Backward compatibility getters
  double get subtotal => subtotalAmount;
  double get total => totalAmount;
  double get igv {
    final net = double.parse((totalAmount / 1.18).toStringAsFixed(2));
    return double.parse((totalAmount - net).toStringAsFixed(2));
  }

  bool get isDraft => status == QuoteStatus.draft;
  bool get isApproved => status == QuoteStatus.approved;
  bool get isCanceled => status == QuoteStatus.canceled;

  factory Quote.calculateAndCreate({
    required String id,
    required String branchId,
    String? workOrderId,
    required String quoteNumber,
    required String customerName,
    String? customerPhone,
    String? vehiclePlate,
    String? vehicleModel,
    required List<dynamic> items,
    double discountPercentage = 0.0,
    DateTime? validUntil,
    QuoteStatus status = QuoteStatus.draft,
    DateTime? createdAt,
  }) {
    final subtotal = items.fold(0.0, (acc, item) {
      if (item is QuoteItem) return acc + item.total;
      if (item is VoucherItem) return acc + item.totalPrice;
      return acc;
    });
    final discount = (subtotal * (discountPercentage / 100.0));
    final total = double.parse((subtotal - discount).toStringAsFixed(2));

    return Quote(
      id: id,
      branchId: branchId,
      workOrderId: workOrderId,
      quoteNumber: quoteNumber,
      customerName: customerName,
      customerPhone: customerPhone ?? '',
      vehiclePlate: vehiclePlate ?? '',
      vehicleModel: vehicleModel ?? '',
      items: items,
      subtotalAmount: double.parse(subtotal.toStringAsFixed(2)),
      discountPercentage: discountPercentage,
      totalAmount: total,
      status: status,
      validUntil: validUntil ?? DateTime.now().add(const Duration(days: 7)),
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
    List<dynamic>? items,
    double? subtotalAmount,
    double? discountPercentage,
    double? totalAmount,
    QuoteStatus? status,
    DateTime? validUntil,
    DateTime? approvedAt,
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
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      validUntil: validUntil ?? this.validUntil,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
