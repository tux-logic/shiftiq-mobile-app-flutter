import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';

/// Data Transfer Object for Quote Items.
class QuoteItemDto {
  final String? id;
  final String type;
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;

  const QuoteItemDto({
    this.id,
    required this.type,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory QuoteItemDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'type': final dynamic t,
        'name': final dynamic n,
        'quantity': final dynamic q,
        'unitPrice': final dynamic u,
        'total': final dynamic tot,
      } =>
        QuoteItemDto(
          id: json['id']?.toString(),
          type: t.toString(),
          name: n.toString(),
          quantity: (q as num).toInt(),
          unitPrice: (u as num).toDouble(),
          total: (tot as num).toDouble(),
        ),
      _ => QuoteItemDto(
          id: json['id']?.toString(),
          type: (json['type'] ?? json['itemType'] ?? 'SERVICE').toString(),
          name: (json['name'] ?? json['description'] ?? '').toString(),
          quantity: ((json['quantity'] ?? 1) as num).toInt(),
          unitPrice: ((json['unitPrice'] ?? 0.0) as num).toDouble(),
          total: ((json['total'] ?? json['totalPrice'] ?? 0.0) as num).toDouble(),
        ),
    };
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'type': type,
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'total': total,
      };

  QuoteItem toDomain() {
    return QuoteItem(
      id: id,
      type: type,
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
    );
  }

  factory QuoteItemDto.fromDomain(QuoteItem item) {
    return QuoteItemDto(
      id: item.id,
      type: item.type,
      name: item.name,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      total: item.total,
    );
  }
}

/// Data Transfer Object for Quotes.
class QuoteDto {
  final String id;
  final String branchId;
  final String? workOrderId;
  final String quoteNumber;
  final String customerName;
  final String customerPhone;
  final String vehiclePlate;
  final String vehicleModel;
  final List<QuoteItemDto> items;
  final double subtotalAmount;
  final double discountPercentage;
  final double totalAmount;
  final String status;
  final String validUntil;
  final String? approvedAt;
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
    this.items = const [],
    required this.subtotalAmount,
    this.discountPercentage = 0.0,
    required this.totalAmount,
    required this.status,
    required this.validUntil,
    this.approvedAt,
    required this.createdAt,
  });

  // Backward compatibility getters
  double get subtotal => subtotalAmount;
  double get total => totalAmount;
  double get igv {
    final net = double.parse((totalAmount / 1.18).toStringAsFixed(2));
    return double.parse((totalAmount - net).toStringAsFixed(2));
  }

  factory QuoteDto.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final parsedItems = rawItems
        .map((i) => QuoteItemDto.fromJson(i as Map<String, dynamic>))
        .toList();

    return switch (json) {
      {
        'id': final dynamic qId,
        'branchId': final dynamic bId,
        'subtotalAmount': final dynamic sub,
        'totalAmount': final dynamic tot,
        'status': final dynamic st,
      } =>
        QuoteDto(
          id: qId.toString(),
          branchId: bId.toString(),
          workOrderId: json['workOrderId']?.toString(),
          quoteNumber: (json['quoteNumber'] ?? 'COT-2026-0042').toString(),
          customerName: (json['customerName'] ?? 'Cliente General').toString(),
          customerPhone: (json['customerPhone'] ?? '').toString(),
          vehiclePlate: (json['vehiclePlate'] ?? '').toString(),
          vehicleModel: (json['vehicleModel'] ?? '').toString(),
          items: parsedItems,
          subtotalAmount: (sub as num).toDouble(),
          discountPercentage: ((json['discountPercentage'] ?? 0.0) as num).toDouble(),
          totalAmount: (tot as num).toDouble(),
          status: st.toString(),
          validUntil: (json['validUntil'] ?? DateTime.now().add(const Duration(days: 7)).toIso8601String()).toString(),
          approvedAt: json['approvedAt']?.toString(),
          createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
        ),
      _ => QuoteDto(
          id: (json['id'] ?? '').toString(),
          branchId: (json['branchId'] ?? '').toString(),
          workOrderId: json['workOrderId']?.toString(),
          quoteNumber: (json['quoteNumber'] ?? '').toString(),
          customerName: (json['customerName'] ?? '').toString(),
          customerPhone: (json['customerPhone'] ?? '').toString(),
          vehiclePlate: (json['vehiclePlate'] ?? '').toString(),
          vehicleModel: (json['vehicleModel'] ?? '').toString(),
          items: parsedItems,
          subtotalAmount: ((json['subtotalAmount'] ?? json['subtotal'] ?? 0.0) as num).toDouble(),
          discountPercentage: ((json['discountPercentage'] ?? 0.0) as num).toDouble(),
          totalAmount: ((json['totalAmount'] ?? json['total'] ?? 0.0) as num).toDouble(),
          status: (json['status'] ?? 'DRAFT').toString(),
          validUntil: (json['validUntil'] ?? DateTime.now().toIso8601String()).toString(),
          approvedAt: json['approvedAt']?.toString(),
          createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
        ),
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'branchId': branchId,
        if (workOrderId != null) 'workOrderId': workOrderId,
        'quoteNumber': quoteNumber,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'vehiclePlate': vehiclePlate,
        'vehicleModel': vehicleModel,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotalAmount': subtotalAmount,
        'discountPercentage': discountPercentage,
        'totalAmount': totalAmount,
        'status': status,
        'validUntil': validUntil,
        if (approvedAt != null) 'approvedAt': approvedAt,
        'createdAt': createdAt,
      };

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
      subtotalAmount: subtotalAmount,
      discountPercentage: discountPercentage,
      totalAmount: totalAmount,
      status: QuoteStatus.fromCode(status),
      validUntil: DateTime.tryParse(validUntil),
      approvedAt: approvedAt != null ? DateTime.tryParse(approvedAt!) : null,
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
      items: quote.items.map((i) {
        if (i is QuoteItem) return QuoteItemDto.fromDomain(i);
        final v = i as VoucherItem;
        return QuoteItemDto(
          id: v.id,
          type: v.itemType.code,
          name: v.description,
          quantity: v.quantity,
          unitPrice: v.unitPrice,
          total: v.totalPrice,
        );
      }).toList(),
      subtotalAmount: quote.subtotalAmount,
      discountPercentage: quote.discountPercentage,
      totalAmount: quote.totalAmount,
      status: quote.status.code,
      validUntil: quote.validUntil.toIso8601String(),
      approvedAt: quote.approvedAt?.toIso8601String(),
      createdAt: quote.createdAt.toIso8601String(),
    );
  }
}

/// Data Transfer Object for Voucher Payments.
class VoucherPaymentDto {
  final String id;
  final double amount;
  final String method;
  final String paidAt;

  const VoucherPaymentDto({
    required this.id,
    required this.amount,
    required this.method,
    required this.paidAt,
  });

  factory VoucherPaymentDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final dynamic pId,
        'amount': final dynamic amt,
        'method': final dynamic mth,
        'paidAt': final dynamic pAt,
      } =>
        VoucherPaymentDto(
          id: pId.toString(),
          amount: (amt as num).toDouble(),
          method: mth.toString(),
          paidAt: pAt.toString(),
        ),
      _ => VoucherPaymentDto(
          id: (json['id'] ?? '').toString(),
          amount: ((json['amount'] ?? 0.0) as num).toDouble(),
          method: (json['method'] ?? 'CASH').toString(),
          paidAt: (json['paidAt'] ?? DateTime.now().toIso8601String()).toString(),
        ),
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'method': method,
        'paidAt': paidAt,
      };

  VoucherPayment toDomain() {
    return VoucherPayment(
      id: id,
      amount: amount,
      method: PaymentMethod.fromCode(method),
      paidAt: DateTime.tryParse(paidAt) ?? DateTime.now(),
    );
  }

  factory VoucherPaymentDto.fromDomain(VoucherPayment payment) {
    return VoucherPaymentDto(
      id: payment.id,
      amount: payment.amount,
      method: payment.method.code,
      paidAt: payment.paidAt.toIso8601String(),
    );
  }
}

/// Data Transfer Object for Voucher Items.
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
    return switch (json) {
      {
        'id': final dynamic iId,
        'description': final dynamic desc,
        'itemType': final dynamic iType,
        'quantity': final dynamic q,
        'unitPrice': final dynamic u,
        'totalPrice': final dynamic tot,
      } =>
        VoucherItemDto(
          id: iId.toString(),
          description: desc.toString(),
          itemType: iType.toString(),
          quantity: (q as num).toInt(),
          unitPrice: (u as num).toDouble(),
          totalPrice: (tot as num).toDouble(),
        ),
      _ => VoucherItemDto(
          id: (json['id'] ?? '').toString(),
          description: (json['description'] ?? json['name'] ?? '').toString(),
          itemType: (json['itemType'] ?? json['type'] ?? 'SERVICIO').toString(),
          quantity: ((json['quantity'] ?? 1) as num).toInt(),
          unitPrice: ((json['unitPrice'] ?? 0.0) as num).toDouble(),
          totalPrice: ((json['totalPrice'] ?? json['total'] ?? 0.0) as num).toDouble(),
        ),
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'itemType': itemType,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };

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

/// Data Transfer Object for Electronic Vouchers.
class VoucherDto {
  final String id;
  final String quoteId;
  final String branchId;
  final String? workOrderId;
  final String series;
  final String correlative;
  final String? fiscalNumber;
  final String voucherType;
  final String customerDocumentType;
  final String customerDocumentNumber;
  final String customerName;
  final String? customerAddress;
  final List<VoucherItemDto> items;
  final double totalAmount;
  final double subtotal;
  final double igv;
  final String paymentMethod;
  final String status;
  final String? externalInvoiceId;
  final String? sunatHash;
  final String? qrData;
  final String? pdfUrl;
  final List<VoucherPaymentDto> payments;
  final double totalPaid;
  final double balance;
  final String issuedAt;
  final String? paidAt;

  const VoucherDto({
    required this.id,
    required this.quoteId,
    required this.branchId,
    this.workOrderId,
    required this.series,
    required this.correlative,
    this.fiscalNumber,
    required this.voucherType,
    required this.customerDocumentType,
    required this.customerDocumentNumber,
    required this.customerName,
    this.customerAddress,
    this.items = const [],
    required this.totalAmount,
    required this.subtotal,
    required this.igv,
    required this.paymentMethod,
    required this.status,
    this.externalInvoiceId,
    this.sunatHash,
    this.qrData,
    this.pdfUrl,
    this.payments = const [],
    this.totalPaid = 0.0,
    this.balance = 0.0,
    required this.issuedAt,
    this.paidAt,
  });

  // Backward compatibility getters
  String get number => correlative;
  double get total => totalAmount;

  factory VoucherDto.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final parsedItems = rawItems
        .map((i) => VoucherItemDto.fromJson(i as Map<String, dynamic>))
        .toList();

    final rawPayments = (json['payments'] as List<dynamic>?) ?? [];
    final parsedPayments = rawPayments
        .map((p) => VoucherPaymentDto.fromJson(p as Map<String, dynamic>))
        .toList();

    return switch (json) {
      {
        'id': final dynamic vId,
        'type': final dynamic vType,
        'customerDocumentType': final dynamic docType,
        'customerDocumentNumber': final dynamic docNum,
        'customerName': final dynamic cName,
        'totalAmount': final dynamic tot,
        'status': final dynamic st,
      } =>
        VoucherDto(
          id: vId.toString(),
          quoteId: (json['quoteId'] ?? vId).toString(),
          branchId: (json['branchId'] ?? '').toString(),
          workOrderId: json['workOrderId']?.toString(),
          series: (json['series'] ?? 'B001').toString(),
          correlative: (json['correlative'] ?? json['number'] ?? '00001234').toString(),
          fiscalNumber: json['fiscalNumber']?.toString(),
          voucherType: vType.toString(),
          customerDocumentType: docType.toString(),
          customerDocumentNumber: docNum.toString(),
          customerName: cName.toString(),
          customerAddress: json['customerAddress']?.toString(),
          items: parsedItems,
          totalAmount: (tot as num).toDouble(),
          subtotal: ((json['subtotal'] ?? (tot.toDouble() / 1.18)) as num).toDouble(),
          igv: ((json['igv'] ?? (tot.toDouble() - (tot.toDouble() / 1.18))) as num).toDouble(),
          paymentMethod: (json['paymentMethod'] ?? 'CASH').toString(),
          status: st.toString(),
          externalInvoiceId: json['externalInvoiceId']?.toString(),
          sunatHash: json['sunatHash']?.toString(),
          qrData: json['qrData']?.toString(),
          pdfUrl: json['pdfUrl']?.toString(),
          payments: parsedPayments,
          totalPaid: ((json['totalPaid'] ?? 0.0) as num).toDouble(),
          balance: ((json['balance'] ?? 0.0) as num).toDouble(),
          issuedAt: (json['issuedAt'] ?? DateTime.now().toIso8601String()).toString(),
          paidAt: json['paidAt']?.toString(),
        ),
      _ => VoucherDto(
          id: (json['id'] ?? '').toString(),
          quoteId: (json['quoteId'] ?? json['id'] ?? '').toString(),
          branchId: (json['branchId'] ?? '').toString(),
          workOrderId: json['workOrderId']?.toString(),
          series: (json['series'] ?? 'B001').toString(),
          correlative: (json['correlative'] ?? json['number'] ?? '00001234').toString(),
          fiscalNumber: json['fiscalNumber']?.toString(),
          voucherType: (json['voucherType'] ?? json['type'] ?? 'RECEIPT').toString(),
          customerDocumentType: (json['customerDocumentType'] ?? 'DNI').toString(),
          customerDocumentNumber: (json['customerDocumentNumber'] ?? '').toString(),
          customerName: (json['customerName'] ?? '').toString(),
          customerAddress: json['customerAddress']?.toString(),
          items: parsedItems,
          totalAmount: ((json['totalAmount'] ?? json['total'] ?? 0.0) as num).toDouble(),
          subtotal: ((json['subtotal'] ?? 0.0) as num).toDouble(),
          igv: ((json['igv'] ?? 0.0) as num).toDouble(),
          paymentMethod: (json['paymentMethod'] ?? 'CASH').toString(),
          status: (json['status'] ?? 'PENDING').toString(),
          externalInvoiceId: json['externalInvoiceId']?.toString(),
          sunatHash: json['sunatHash']?.toString(),
          qrData: json['qrData']?.toString(),
          pdfUrl: json['pdfUrl']?.toString(),
          payments: parsedPayments,
          totalPaid: ((json['totalPaid'] ?? 0.0) as num).toDouble(),
          balance: ((json['balance'] ?? 0.0) as num).toDouble(),
          issuedAt: (json['issuedAt'] ?? DateTime.now().toIso8601String()).toString(),
          paidAt: json['paidAt']?.toString(),
        ),
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quoteId': quoteId,
        'branchId': branchId,
        if (workOrderId != null) 'workOrderId': workOrderId,
        'series': series,
        'correlative': correlative,
        if (fiscalNumber != null) 'fiscalNumber': fiscalNumber,
        'voucherType': voucherType,
        'customerDocumentType': customerDocumentType,
        'customerDocumentNumber': customerDocumentNumber,
        'customerName': customerName,
        if (customerAddress != null) 'customerAddress': customerAddress,
        'items': items.map((i) => i.toJson()).toList(),
        'totalAmount': totalAmount,
        'subtotal': subtotal,
        'igv': igv,
        'paymentMethod': paymentMethod,
        'status': status,
        if (externalInvoiceId != null) 'externalInvoiceId': externalInvoiceId,
        if (sunatHash != null) 'sunatHash': sunatHash,
        if (qrData != null) 'qrData': qrData,
        if (pdfUrl != null) 'pdfUrl': pdfUrl,
        'payments': payments.map((p) => p.toJson()).toList(),
        'totalPaid': totalPaid,
        'balance': balance,
        'issuedAt': issuedAt,
        if (paidAt != null) 'paidAt': paidAt,
      };

  ElectronicVoucher toDomain() {
    return ElectronicVoucher(
      id: id,
      quoteId: quoteId,
      branchId: branchId,
      workOrderId: workOrderId,
      type: VoucherType.fromCode(voucherType),
      customerDocumentType: customerDocumentType,
      customerDocumentNumber: customerDocumentNumber,
      customerName: customerName,
      customerAddress: customerAddress,
      totalAmount: totalAmount,
      status: VoucherStatus.fromCode(status),
      externalInvoiceId: externalInvoiceId,
      series: series,
      correlative: correlative,
      fiscalNumber: fiscalNumber,
      pdfUrl: pdfUrl,
      payments: payments.map((p) => p.toDomain()).toList(),
      totalPaid: totalPaid,
      balance: balance,
      items: items.map((i) => i.toDomain()).toList(),
      sunatHash: sunatHash,
      qrData: qrData,
      issuedAt: DateTime.tryParse(issuedAt) ?? DateTime.now(),
      paidAt: paidAt != null ? DateTime.tryParse(paidAt!) : null,
    );
  }

  factory VoucherDto.fromDomain(ElectronicVoucher voucher) {
    return VoucherDto(
      id: voucher.id,
      quoteId: voucher.quoteId,
      branchId: voucher.branchId,
      workOrderId: voucher.workOrderId,
      series: voucher.series,
      correlative: voucher.correlative,
      fiscalNumber: voucher.fiscalNumber,
      voucherType: voucher.type.code,
      customerDocumentType: voucher.customerDocumentType,
      customerDocumentNumber: voucher.customerDocumentNumber,
      customerName: voucher.customerName,
      customerAddress: voucher.customerAddress,
      items: voucher.items.map((i) => VoucherItemDto.fromDomain(i)).toList(),
      totalAmount: voucher.totalAmount,
      subtotal: voucher.subtotal,
      igv: voucher.igv,
      paymentMethod: voucher.paymentMethod.code,
      status: voucher.status.code,
      externalInvoiceId: voucher.externalInvoiceId,
      sunatHash: voucher.sunatHash,
      qrData: voucher.qrData,
      pdfUrl: voucher.pdfUrl,
      payments: voucher.payments.map((p) => VoucherPaymentDto.fromDomain(p)).toList(),
      totalPaid: voucher.totalPaid,
      balance: voucher.balance,
      issuedAt: voucher.issuedAt.toIso8601String(),
      paidAt: voucher.paidAt?.toIso8601String(),
    );
  }
}

/// Data Transfer Object for Mercado Pago Preferences.
class MercadoPagoPreferenceDto {
  final String preferenceId;
  final String initPoint;
  final String sandboxInitPoint;
  final double amount;
  final String currency;
  final String externalReference;

  const MercadoPagoPreferenceDto({
    required this.preferenceId,
    required this.initPoint,
    required this.sandboxInitPoint,
    required this.amount,
    required this.currency,
    required this.externalReference,
  });

  factory MercadoPagoPreferenceDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'preferenceId': final dynamic pId,
        'initPoint': final dynamic init,
        'sandboxInitPoint': final dynamic sand,
        'amount': final dynamic amt,
        'currency': final dynamic curr,
        'externalReference': final dynamic ext,
      } =>
        MercadoPagoPreferenceDto(
          preferenceId: pId.toString(),
          initPoint: init.toString(),
          sandboxInitPoint: sand.toString(),
          amount: (amt as num).toDouble(),
          currency: curr.toString(),
          externalReference: ext.toString(),
        ),
      _ => MercadoPagoPreferenceDto(
          preferenceId: (json['preferenceId'] ?? '').toString(),
          initPoint: (json['initPoint'] ?? '').toString(),
          sandboxInitPoint: (json['sandboxInitPoint'] ?? '').toString(),
          amount: ((json['amount'] ?? 0.0) as num).toDouble(),
          currency: (json['currency'] ?? 'PEN').toString(),
          externalReference: (json['externalReference'] ?? '').toString(),
        ),
    };
  }

  Map<String, dynamic> toJson() => {
        'preferenceId': preferenceId,
        'initPoint': initPoint,
        'sandboxInitPoint': sandboxInitPoint,
        'amount': amount,
        'currency': currency,
        'externalReference': externalReference,
      };

  MercadoPagoPreference toDomain() {
    return MercadoPagoPreference(
      preferenceId: preferenceId,
      initPoint: initPoint,
      sandboxInitPoint: sandboxInitPoint,
      amount: amount,
      currency: currency,
      externalReference: externalReference,
    );
  }

  factory MercadoPagoPreferenceDto.fromDomain(MercadoPagoPreference pref) {
    return MercadoPagoPreferenceDto(
      preferenceId: pref.preferenceId,
      initPoint: pref.initPoint,
      sandboxInitPoint: pref.sandboxInitPoint,
      amount: pref.amount,
      currency: pref.currency,
      externalReference: pref.externalReference,
    );
  }
}
