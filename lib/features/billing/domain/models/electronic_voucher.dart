import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/voucher_type.dart';

enum VoucherItemType {
  service('SERVICIO', 'Mano de Obra / Servicio'),
  sparePart('REPUESTO', 'Repuesto / Autoparte');

  final String code;
  final String label;

  const VoucherItemType(this.code, this.label);

  static VoucherItemType fromCode(String code) {
    if (code.toUpperCase() == 'REPUESTO' || code.toUpperCase() == 'PRODUCT') {
      return VoucherItemType.sparePart;
    }
    return VoucherItemType.service;
  }
}

class VoucherItem {
  final String id;
  final String description;
  final VoucherItemType itemType;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

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
      totalPrice: double.parse((quantity * unitPrice).toStringAsFixed(2)),
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

class VoucherPayment {
  final String id;
  final double amount;
  final PaymentMethod method;
  final DateTime paidAt;

  const VoucherPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.paidAt,
  });

  VoucherPayment copyWith({
    String? id,
    double? amount,
    PaymentMethod? method,
    DateTime? paidAt,
  }) {
    return VoucherPayment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

class ElectronicVoucher {
  final String id;
  final String quoteId;
  final String branchId;
  final String workOrderId;
  final VoucherType type;
  final String customerDocumentType;
  final String customerDocumentNumber;
  final String customerName;
  final String? customerAddress;
  final double totalAmount;
  final VoucherStatus status;
  final String? externalInvoiceId;
  final String series;
  final String correlative;
  final String fiscalNumber;
  final String? pdfUrl;
  final List<VoucherPayment> payments;
  final double totalPaid;
  final double balance;
  final List<VoucherItem> items;
  final String sunatHash;
  final String? qrData;
  final DateTime issuedAt;
  final DateTime? paidAt;

  ElectronicVoucher({
    required this.id,
    String? quoteId,
    required this.branchId,
    String? workOrderId,
    VoucherType? type,
    VoucherType? voucherType,
    required this.customerDocumentType,
    required this.customerDocumentNumber,
    required this.customerName,
    this.customerAddress,
    double? totalAmount,
    double? total,
    double? subtotal,
    double? igv,
    required this.status,
    this.externalInvoiceId,
    String? series,
    String? correlative,
    String? number,
    String? fiscalNumber,
    this.pdfUrl,
    this.payments = const [],
    double? totalPaid,
    double? balance,
    this.items = const [],
    String? sunatHash,
    this.qrData,
    PaymentMethod? paymentMethod,
    DateTime? issuedAt,
    this.paidAt,
  })  : quoteId = quoteId ?? id,
        workOrderId = workOrderId ?? '',
        type = type ?? voucherType ?? VoucherType.receipt,
        series = series ?? 'B001',
        correlative = correlative ?? number ?? (id.length > 7 ? id.substring(id.length - 7) : id),
        fiscalNumber = fiscalNumber ?? '${series ?? "B001"}-${correlative ?? number ?? (id.length > 7 ? id.substring(id.length - 7) : id)}',
        totalAmount = totalAmount ?? total ?? 0.0,
        totalPaid = totalPaid ?? 0.0,
        balance = balance ?? ((totalAmount ?? total ?? 0.0) - (totalPaid ?? 0.0)),
        sunatHash = sunatHash ?? 'HASH-SUNAT-SHA256-${id.length > 8 ? id.substring(0, 8).toUpperCase() : id}',
        issuedAt = issuedAt ?? DateTime.now();

  // Backward compatibility getters
  VoucherType get voucherType => type;
  String get number => correlative;
  String get fullCode => fiscalNumber;
  bool get isPaid => status == VoucherStatus.paid || totalPaid >= totalAmount;
  double get total => totalAmount;
  double get subtotal => double.parse((totalAmount / 1.18).toStringAsFixed(2));
  double get igv => double.parse((totalAmount - subtotal).toStringAsFixed(2));
  PaymentMethod get paymentMethod =>
      payments.isNotEmpty ? payments.last.method : PaymentMethod.cash;

  factory ElectronicVoucher.calculateAndCreate({
    required String id,
    String? quoteId,
    required String branchId,
    String? workOrderId,
    required String series,
    required String number,
    required VoucherType voucherType,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    String? customerAddress,
    required List<VoucherItem> items,
    required PaymentMethod paymentMethod,
    VoucherStatus status = VoucherStatus.emitted,
    String? sunatHash,
    DateTime? issuedAt,
    DateTime? paidAt,
  }) {
    final double totalCalculated =
        items.fold(0.0, (acc, item) => acc + item.totalPrice);
    final double subtotalCalculated =
        double.parse((totalCalculated / 1.18).toStringAsFixed(2));
    final double igvCalculated =
        double.parse((totalCalculated - subtotalCalculated).toStringAsFixed(2));

    final date = issuedAt ?? DateTime.now();
    final hash =
        sunatHash ?? 'HASH-SUNAT-SHA256-${id.length > 8 ? id.substring(0, 8).toUpperCase() : id}';

    final sunatTypeCode =
        voucherType == VoucherType.invoice ? 'FACTURA' : 'BOLETA';
    final qr =
        '20601234567|$sunatTypeCode|$series|$number|$igvCalculated|$totalCalculated|${date.toIso8601String().split('T').first}|$customerDocumentType|$customerDocumentNumber|$hash';

    final isAlreadyPaid = status == VoucherStatus.paid;
    final List<VoucherPayment> initialPayments = isAlreadyPaid
        ? [
            VoucherPayment(
              id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
              amount: totalCalculated,
              method: paymentMethod,
              paidAt: paidAt ?? date,
            ),
          ]
        : [];

    return ElectronicVoucher(
      id: id,
      quoteId: quoteId ?? id,
      branchId: branchId,
      workOrderId: workOrderId ?? '',
      type: voucherType,
      customerDocumentType: customerDocumentType,
      customerDocumentNumber: customerDocumentNumber,
      customerName: customerName,
      customerAddress: customerAddress,
      totalAmount: totalCalculated,
      status: status,
      series: series,
      correlative: number,
      fiscalNumber: '$series-$number',
      pdfUrl: 'https://shiftiq-platform.onrender.com/vouchers/$series-$number.pdf',
      payments: initialPayments,
      totalPaid: isAlreadyPaid ? totalCalculated : 0.0,
      balance: isAlreadyPaid ? 0.0 : totalCalculated,
      items: items,
      sunatHash: hash,
      qrData: qr,
      issuedAt: date,
      paidAt: paidAt,
    );
  }

  ElectronicVoucher copyWith({
    String? id,
    String? quoteId,
    String? branchId,
    String? workOrderId,
    VoucherType? type,
    String? customerDocumentType,
    String? customerDocumentNumber,
    String? customerName,
    String? customerAddress,
    double? totalAmount,
    VoucherStatus? status,
    String? externalInvoiceId,
    String? series,
    String? correlative,
    String? fiscalNumber,
    String? pdfUrl,
    List<VoucherPayment>? payments,
    PaymentMethod? paymentMethod,
    double? totalPaid,
    double? balance,
    List<VoucherItem>? items,
    String? sunatHash,
    String? qrData,
    DateTime? issuedAt,
    DateTime? paidAt,
  }) {
    List<VoucherPayment> updatedPayments = payments ?? this.payments;
    if (paymentMethod != null && payments == null) {
      updatedPayments = [
        ...this.payments,
        VoucherPayment(
          id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
          amount: totalAmount ?? this.totalAmount,
          method: paymentMethod,
          paidAt: paidAt ?? DateTime.now(),
        ),
      ];
    }

    return ElectronicVoucher(
      id: id ?? this.id,
      quoteId: quoteId ?? this.quoteId,
      branchId: branchId ?? this.branchId,
      workOrderId: workOrderId ?? this.workOrderId,
      type: type ?? this.type,
      customerDocumentType: customerDocumentType ?? this.customerDocumentType,
      customerDocumentNumber:
          customerDocumentNumber ?? this.customerDocumentNumber,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      externalInvoiceId: externalInvoiceId ?? this.externalInvoiceId,
      series: series ?? this.series,
      correlative: correlative ?? this.correlative,
      fiscalNumber: fiscalNumber ?? this.fiscalNumber,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      payments: updatedPayments,
      totalPaid: totalPaid ?? this.totalPaid,
      balance: balance ?? this.balance,
      items: items ?? this.items,
      sunatHash: sunatHash ?? this.sunatHash,
      qrData: qrData ?? this.qrData,
      issuedAt: issuedAt ?? this.issuedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
