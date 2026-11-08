import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/electronic_voucher.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_type.dart';

class VoucherItemDto {
  final String id;
  final String description;
  final String itemType;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const VoucherItemDto({
    required this.id,
    required this.description,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory VoucherItemDto.fromJson(Map<String, dynamic> json) {
    return VoucherItemDto(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      itemType: json['itemType'] as String? ?? 'SERVICIO',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'itemType': itemType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  VoucherItem toDomain() {
    return VoucherItem(
      id: id,
      description: description,
      itemType: VoucherItemType.fromCode(itemType),
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }

  factory VoucherItemDto.fromDomain(VoucherItem item) {
    return VoucherItemDto(
      id: item.id,
      description: item.description,
      itemType: item.itemType.code,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalPrice: item.totalPrice,
    );
  }
}

class VoucherDto {
  final String id;
  final String branchId;
  final String workOrderId;
  final String series;
  final String number;
  final String voucherType;
  final String customerDocumentType;
  final String customerDocumentNumber;
  final String customerName;
  final String? customerAddress;
  final List<VoucherItemDto> items;
  final double subtotal;
  final double igv;
  final double total;
  final String paymentMethod;
  final String status;
  final String sunatHash;
  final String? qrData;
  final String? pdfUrl;
  final String issuedAt;
  final String? paidAt;

  const VoucherDto({
    required this.id,
    required this.branchId,
    required this.workOrderId,
    required this.series,
    required this.number,
    required this.voucherType,
    required this.customerDocumentType,
    required this.customerDocumentNumber,
    required this.customerName,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.sunatHash,
    this.qrData,
    this.pdfUrl,
    required this.issuedAt,
    this.paidAt,
  });

  factory VoucherDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return VoucherDto(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      workOrderId: json['workOrderId'] as String? ?? '',
      series: json['series'] as String? ?? '',
      number: json['number'] as String? ?? '',
      voucherType: json['voucherType'] as String? ?? 'BOLETA',
      customerDocumentType: json['customerDocumentType'] as String? ?? 'DNI',
      customerDocumentNumber:
          json['customerDocumentNumber'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerAddress: json['customerAddress'] as String?,
      items: rawItems
          .map((i) => VoucherItemDto.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      igv: (json['igv'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'EFECTIVO',
      status: json['status'] as String? ?? 'EMITIDO',
      sunatHash: json['sunatHash'] as String? ?? '',
      qrData: json['qrData'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      issuedAt: json['issuedAt'] as String? ??
          DateTime.now().toIso8601String(),
      paidAt: json['paidAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'workOrderId': workOrderId,
      'series': series,
      'number': number,
      'voucherType': voucherType,
      'customerDocumentType': customerDocumentType,
      'customerDocumentNumber': customerDocumentNumber,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'igv': igv,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'sunatHash': sunatHash,
      'qrData': qrData,
      'pdfUrl': pdfUrl,
      'issuedAt': issuedAt,
      'paidAt': paidAt,
    };
  }

  ElectronicVoucher toDomain() {
    return ElectronicVoucher(
      id: id,
      branchId: branchId,
      workOrderId: workOrderId,
      series: series,
      number: number,
      voucherType: VoucherType.fromCode(voucherType),
      customerDocumentType: customerDocumentType,
      customerDocumentNumber: customerDocumentNumber,
      customerName: customerName,
      customerAddress: customerAddress,
      items: items.map((i) => i.toDomain()).toList(),
      subtotal: subtotal,
      igv: igv,
      total: total,
      paymentMethod: PaymentMethod.fromCode(paymentMethod),
      status: VoucherStatus.fromCode(status),
      sunatHash: sunatHash,
      qrData: qrData,
      pdfUrl: pdfUrl,
      issuedAt: DateTime.tryParse(issuedAt) ?? DateTime.now(),
      paidAt: paidAt != null ? DateTime.tryParse(paidAt!) : null,
    );
  }

  factory VoucherDto.fromDomain(ElectronicVoucher voucher) {
    return VoucherDto(
      id: voucher.id,
      branchId: voucher.branchId,
      workOrderId: voucher.workOrderId,
      series: voucher.series,
      number: voucher.number,
      voucherType: voucher.voucherType.code,
      customerDocumentType: voucher.customerDocumentType,
      customerDocumentNumber: voucher.customerDocumentNumber,
      customerName: voucher.customerName,
      customerAddress: voucher.customerAddress,
      items: voucher.items.map((i) => VoucherItemDto.fromDomain(i)).toList(),
      subtotal: voucher.subtotal,
      igv: voucher.igv,
      total: voucher.total,
      paymentMethod: voucher.paymentMethod.code,
      status: voucher.status.code,
      sunatHash: voucher.sunatHash,
      qrData: voucher.qrData,
      pdfUrl: voucher.pdfUrl,
      issuedAt: voucher.issuedAt.toIso8601String(),
      paidAt: voucher.paidAt?.toIso8601String(),
    );
  }
}
