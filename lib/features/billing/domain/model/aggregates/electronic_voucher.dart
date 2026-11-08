import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_type.dart';

class ElectronicVoucher {
  final String id;
  final String branchId;
  final String workOrderId;
  final String series; // B001, F001, NV01
  final String number; // 0000482
  final VoucherType voucherType;
  final String customerDocumentType; // DNI, RUC
  final String customerDocumentNumber;
  final String customerName;
  final String? customerAddress;
  final List<VoucherItem> items;
  final double subtotal; // Base imponible
  final double igv; // 18% SUNAT
  final double total; // Monto total en PEN
  final PaymentMethod paymentMethod;
  final VoucherStatus status;
  final String sunatHash;
  final String? qrData;
  final String? pdfUrl;
  final DateTime issuedAt;
  final DateTime? paidAt;

  const ElectronicVoucher({
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

  String get fullCode => '$series-$number';

  bool get isPaid => status == VoucherStatus.paid;

  /// Helper factory to compute Peruvian SUNAT 18% IGV accurately
  factory ElectronicVoucher.calculateAndCreate({
    required String id,
    required String branchId,
    required String workOrderId,
    required String series,
    required String number,
    required VoucherType voucherType,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    String? customerAddress,
    required List<VoucherItem> items,
    required PaymentMethod paymentMethod,
    VoucherStatus status = VoucherStatus.issued,
    String? sunatHash,
    DateTime? issuedAt,
    DateTime? paidAt,
  }) {
    final double totalCalculated =
        items.fold(0.0, (acc, item) => acc + item.totalPrice);
    // In Peru: Total includes 18% IGV -> Subtotal = Total / 1.18, IGV = Total - Subtotal
    final double subtotalCalculated =
        double.parse((totalCalculated / 1.18).toStringAsFixed(2));
    final double igvCalculated =
        double.parse((totalCalculated - subtotalCalculated).toStringAsFixed(2));

    final date = issuedAt ?? DateTime.now();
    final hash = sunatHash ?? 'HASH-SUNAT-SHA256-${id.substring(0, 8).toUpperCase()}';
    
    // Peruvian standard SUNAT QR string
    final qr =
        '20601234567|${voucherType.code}|$series|$number|$igvCalculated|$totalCalculated|${date.toIso8601String().split('T').first}|$customerDocumentType|$customerDocumentNumber|$hash';

    return ElectronicVoucher(
      id: id,
      branchId: branchId,
      workOrderId: workOrderId,
      series: series,
      number: number,
      voucherType: voucherType,
      customerDocumentType: customerDocumentType,
      customerDocumentNumber: customerDocumentNumber,
      customerName: customerName,
      customerAddress: customerAddress,
      items: items,
      subtotal: subtotalCalculated,
      igv: igvCalculated,
      total: totalCalculated,
      paymentMethod: paymentMethod,
      status: status,
      sunatHash: hash,
      qrData: qr,
      pdfUrl: 'https://shiftiq-platform.onrender.com/vouchers/$series-$number.pdf',
      issuedAt: date,
      paidAt: paidAt,
    );
  }

  ElectronicVoucher copyWith({
    String? id,
    String? branchId,
    String? workOrderId,
    String? series,
    String? number,
    VoucherType? voucherType,
    String? customerDocumentType,
    String? customerDocumentNumber,
    String? customerName,
    String? customerAddress,
    List<VoucherItem>? items,
    double? subtotal,
    double? igv,
    double? total,
    PaymentMethod? paymentMethod,
    VoucherStatus? status,
    String? sunatHash,
    String? qrData,
    String? pdfUrl,
    DateTime? issuedAt,
    DateTime? paidAt,
  }) {
    return ElectronicVoucher(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      workOrderId: workOrderId ?? this.workOrderId,
      series: series ?? this.series,
      number: number ?? this.number,
      voucherType: voucherType ?? this.voucherType,
      customerDocumentType:
          customerDocumentType ?? this.customerDocumentType,
      customerDocumentNumber:
          customerDocumentNumber ?? this.customerDocumentNumber,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      igv: igv ?? this.igv,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      sunatHash: sunatHash ?? this.sunatHash,
      qrData: qrData ?? this.qrData,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      issuedAt: issuedAt ?? this.issuedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
