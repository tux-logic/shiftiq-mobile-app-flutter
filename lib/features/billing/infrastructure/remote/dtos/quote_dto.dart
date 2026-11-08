import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/quote.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/dtos/voucher_dto.dart';

class QuoteDto {
  final String id;
  final String branchId;
  final String? workOrderId;
  final String quoteNumber;
  final String customerName;
  final String customerPhone;
  final String vehiclePlate;
  final String vehicleModel;
  final List<VoucherItemDto> items;
  final double subtotal;
  final double igv;
  final double total;
  final String validUntil;
  final String status;
  final String createdAt;

  const QuoteDto({
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

  factory QuoteDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return QuoteDto(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      workOrderId: json['workOrderId'] as String?,
      quoteNumber: json['quoteNumber'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      vehiclePlate: json['vehiclePlate'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      items: rawItems
          .map((i) => VoucherItemDto.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      igv: (json['igv'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      validUntil: json['validUntil'] as String? ??
          DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      status: json['status'] as String? ?? 'BORRADOR',
      createdAt: json['createdAt'] as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'workOrderId': workOrderId,
      'quoteNumber': quoteNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'vehiclePlate': vehiclePlate,
      'vehicleModel': vehicleModel,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'igv': igv,
      'total': total,
      'validUntil': validUntil,
      'status': status,
      'createdAt': createdAt,
    };
  }

  Quote toDomain() {
    return Quote(
      id: id,
      branchId: branchId,
      workOrderId: workOrderId,
      quoteNumber: quoteNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      items: items.map((i) => i.toDomain()).toList(),
      subtotal: subtotal,
      igv: igv,
      total: total,
      validUntil: DateTime.tryParse(validUntil) ??
          DateTime.now().add(const Duration(days: 7)),
      status: QuoteStatus.fromCode(status),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  factory QuoteDto.fromDomain(Quote quote) {
    return QuoteDto(
      id: quote.id,
      branchId: quote.branchId,
      workOrderId: quote.workOrderId,
      quoteNumber: quote.quoteNumber,
      customerName: quote.customerName,
      customerPhone: quote.customerPhone,
      vehiclePlate: quote.vehiclePlate,
      vehicleModel: quote.vehicleModel,
      items: quote.items.map((i) => VoucherItemDto.fromDomain(i)).toList(),
      subtotal: quote.subtotal,
      igv: quote.igv,
      total: quote.total,
      validUntil: quote.validUntil.toIso8601String(),
      status: quote.status.code,
      createdAt: quote.createdAt.toIso8601String(),
    );
  }
}
