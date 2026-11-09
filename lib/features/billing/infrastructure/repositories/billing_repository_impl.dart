import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/billing_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/dtos/quote_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/dtos/voucher_dto.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingApi billingApi;
  final List<ElectronicVoucher> _localVouchers = [];
  final List<Quote> _localQuotes = [];

  BillingRepositoryImpl({required this.billingApi}) {
    _seedInitialData();
  }

  void _seedInitialData() {
    _localVouchers.addAll([
      ElectronicVoucher.calculateAndCreate(
        id: 'vouch-01-boleta',
        branchId: 'b-01-smp',
        workOrderId: 'w1w2w3w4-1111-2222-3333-444455556666',
        series: 'B001',
        number: '0000482',
        voucherType: VoucherType.boleta,
        customerDocumentType: 'DNI',
        customerDocumentNumber: '45678901',
        customerName: 'Carlos Mendoza',
        customerAddress: 'Av. Universitaria 1240, San Martín de Porres, Lima',
        items: const [
          VoucherItem(
            id: 'item-1',
            description: 'Diagnóstico Computarizado OBD-II y Escaneo',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 80.0,
            totalPrice: 80.0,
          ),
          VoucherItem(
            id: 'item-2',
            description: 'Mano de Obra Cambio de Pastillas de Freno',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 120.0,
            totalPrice: 120.0,
          ),
          VoucherItem(
            id: 'item-3',
            description: 'Pastillas de Freno Bosch Delanteras Hilux',
            itemType: VoucherItemType.sparePart,
            quantity: 1,
            unitPrice: 100.0,
            totalPrice: 100.0,
          ),
          VoucherItem(
            id: 'item-4',
            description: 'Rectificado de Discos Ventilados Delanteros',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 150.0,
            totalPrice: 150.0,
          ),
        ],
        paymentMethod: PaymentMethod.cash,
        status: VoucherStatus.paid,
        issuedAt: DateTime.now().subtract(const Duration(hours: 4)),
        paidAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
      ),
      ElectronicVoucher.calculateAndCreate(
        id: 'vouch-02-factura',
        branchId: 'b-01-smp',
        workOrderId: 'w2w3w4w5-2222-3333-4444-555566667777',
        series: 'F001',
        number: '0000128',
        voucherType: VoucherType.factura,
        customerDocumentType: 'RUC',
        customerDocumentNumber: '20601893451',
        customerName: 'Transportes Rápidos Lima S.A.C.',
        customerAddress: 'Calle Los Hornos 450, Urb. Fiori, SMP',
        items: const [
          VoucherItem(
            id: 'item-201',
            description: 'Mantenimiento Preventivo 40,000 km Flota',
            itemType: VoucherItemType.service,
            quantity: 2,
            unitPrice: 450.0,
            totalPrice: 900.0,
          ),
          VoucherItem(
            id: 'item-202',
            description: 'Aceite Sintético Castrol Edge 5W-30 (Galón)',
            itemType: VoucherItemType.sparePart,
            quantity: 4,
            unitPrice: 180.0,
            totalPrice: 720.0,
          ),
          VoucherItem(
            id: 'item-203',
            description: 'Filtro de Aceite Bosch P3300 Original',
            itemType: VoucherItemType.sparePart,
            quantity: 2,
            unitPrice: 45.0,
            totalPrice: 90.0,
          ),
          VoucherItem(
            id: 'item-204',
            description: 'Alineación Láser y Balanceo de Ejes',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 140.0,
            totalPrice: 140.0,
          ),
        ],
        paymentMethod: PaymentMethod.bankTransfer,
        status: VoucherStatus.issued,
        issuedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    _localQuotes.addAll([
      Quote.calculateAndCreate(
        id: 'quote-01',
        branchId: 'b-01-smp',
        workOrderId: 'w1w2w3w4-1111-2222-3333-444455556666',
        quoteNumber: 'COT-2026-0042',
        customerName: 'Carlos Mendoza',
        customerPhone: '+51 987 654 321',
        vehiclePlate: 'ABC-123',
        vehicleModel: 'Toyota Hilux 2021',
        validUntil: DateTime.now().add(const Duration(days: 7)),
        status: QuoteStatus.approved,
        items: const [
          VoucherItem(
            id: 'qi-1',
            description: 'Diagnóstico Computarizado OBD-II y Escaneo',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 80.0,
            totalPrice: 80.0,
          ),
          VoucherItem(
            id: 'qi-2',
            description: 'Cambio de Pastillas de Freno Delanteras',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 120.0,
            totalPrice: 120.0,
          ),
          VoucherItem(
            id: 'qi-3',
            description: 'Pastillas Bosch Delanteras Hilux',
            itemType: VoucherItemType.sparePart,
            quantity: 1,
            unitPrice: 100.0,
            totalPrice: 100.0,
          ),
          VoucherItem(
            id: 'qi-4',
            description: 'Rectificado de Discos Delanteros',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 150.0,
            totalPrice: 150.0,
          ),
        ],
      ),
      Quote.calculateAndCreate(
        id: 'quote-02',
        branchId: 'b-01-smp',
        quoteNumber: 'COT-2026-0043',
        customerName: 'Andrea Benavente',
        customerPhone: '+51 912 345 678',
        vehiclePlate: 'F1G-789',
        vehicleModel: 'Kia Sportage 2022',
        validUntil: DateTime.now().add(const Duration(days: 5)),
        status: QuoteStatus.sent,
        items: const [
          VoucherItem(
            id: 'qi-21',
            description: 'Limpieza de Inyectores por Ultrasonido',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 180.0,
            totalPrice: 180.0,
          ),
          VoucherItem(
            id: 'qi-22',
            description: 'Limpieza de Sensor MAF y Cuerpo de Aceleración',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 90.0,
            totalPrice: 90.0,
          ),
        ],
      ),
    ]);
  }

  @override
  Future<List<ElectronicVoucher>> getVouchers({
    required String branchId,
    VoucherType? voucherType,
    VoucherStatus? status,
  }) async {
    try {
      final dtos = await billingApi.getVouchers(
        branchId: branchId,
        voucherType: voucherType?.code,
        status: status?.code,
      );
      if (dtos.isNotEmpty) {
        return dtos.map((d) => d.toDomain()).toList();
      }
    } catch (_) {
      // Local fallback
    }

    var list = _localVouchers
        .where((v) => v.branchId == branchId || branchId.isEmpty)
        .toList();

    if (voucherType != null) {
      list = list.where((v) => v.voucherType == voucherType).toList();
    }

    if (status != null) {
      list = list.where((v) => v.status == status).toList();
    }

    list.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return list;
  }

  @override
  Future<ElectronicVoucher> getVoucherById(String id) async {
    try {
      final dto = await billingApi.getVoucherById(id);
      return dto.toDomain();
    } catch (_) {
      // Local fallback
    }

    return _localVouchers.firstWhere(
      (v) => v.id == id,
      orElse: () => throw Exception('Comprobante electrónico no encontrado: $id'),
    );
  }

  @override
  Future<ElectronicVoucher> emitVoucher({
    String quoteId = '',
    String branchId = '',
    String workOrderId = '',
    required VoucherType voucherType,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    String? customerAddress,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    List<VoucherItem> items = const [],
  }) async {
    final nextNumber = (_localVouchers.length + 483).toString().padLeft(7, '0');
    final series = voucherType.defaultSeries;

    final voucher = ElectronicVoucher.calculateAndCreate(
      id: 'vouch-${DateTime.now().millisecondsSinceEpoch}',
      quoteId: quoteId.isNotEmpty ? quoteId : null,
      branchId: branchId,
      workOrderId: workOrderId,
      series: series,
      number: nextNumber,
      voucherType: voucherType,
      customerDocumentType: customerDocumentType,
      customerDocumentNumber: customerDocumentNumber,
      customerName: customerName,
      customerAddress: customerAddress,
      items: items,
      paymentMethod: paymentMethod,
      status: paymentMethod == PaymentMethod.cash
          ? VoucherStatus.paid
          : VoucherStatus.emitted,
      paidAt: paymentMethod == PaymentMethod.cash ? DateTime.now() : null,
    );

    try {
      final dto = await billingApi.emitVoucher(
        VoucherDto.fromDomain(voucher).toJson(),
      );
      final remoteDomain = dto.toDomain();
      _localVouchers.insert(0, remoteDomain);
      return remoteDomain;
    } catch (_) {
      // Local fallback
      _localVouchers.insert(0, voucher);
      return voucher;
    }
  }

  @override
  Future<ElectronicVoucher> processPayment({
    required String voucherId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final dto = await billingApi.processPayment(
        voucherId,
        {'paymentMethod': paymentMethod.code},
      );
      final updated = dto.toDomain();
      final idx = _localVouchers.indexWhere((v) => v.id == voucherId);
      if (idx != -1) _localVouchers[idx] = updated;
      return updated;
    } catch (_) {
      // Local fallback
    }

    final index = _localVouchers.indexWhere((v) => v.id == voucherId);
    if (index != -1) {
      final current = _localVouchers[index];
      final paidVoucher = current.copyWith(
        status: VoucherStatus.paid,
        paymentMethod: paymentMethod,
        paidAt: DateTime.now(),
      );
      _localVouchers[index] = paidVoucher;
      return paidVoucher;
    }

    throw Exception('No se encontró comprobante para registrar pago: $voucherId');
  }

  @override
  Future<List<Quote>> getQuotes({required String branchId}) async {
    try {
      final dtos = await billingApi.getQuotes(branchId: branchId);
      if (dtos.isNotEmpty) {
        return dtos.map((d) => d.toDomain()).toList();
      }
    } catch (_) {
      // Local fallback
    }

    return _localQuotes
        .where((q) => q.branchId == branchId || branchId.isEmpty)
        .toList();
  }

  @override
  Future<Quote> createQuote({
    required String branchId,
    String? workOrderId,
    double discountPercentage = 0.0,
    String customerName = '',
    String customerPhone = '',
    String vehiclePlate = '',
    String vehicleModel = '',
    List<dynamic> items = const [],
    DateTime? validUntil,
  }) async {
    final quoteNumber = 'COT-2026-${(_localQuotes.length + 43).toString().padLeft(4, '0')}';
    final quote = Quote.calculateAndCreate(
      id: 'quote-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      workOrderId: workOrderId,
      quoteNumber: quoteNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      items: items,
      discountPercentage: discountPercentage,
      validUntil: validUntil,
      status: QuoteStatus.draft,
    );

    try {
      final dto = await billingApi.createQuote(QuoteDto.fromDomain(quote).toJson());
      final domain = dto.toDomain();
      _localQuotes.insert(0, domain);
      return domain;
    } catch (_) {
      // Local fallback
      _localQuotes.insert(0, quote);
      return quote;
    }
  }

  @override
  Future<Quote> getQuoteById(String quoteId) async {
    try {
      final dto = await billingApi.getQuoteById(quoteId);
      return dto.toDomain();
    } catch (_) {
      // Local fallback
    }

    return _localQuotes.firstWhere(
      (q) => q.id == quoteId,
      orElse: () => throw Exception('Quote not found: $quoteId'),
    );
  }

  @override
  Future<Quote> updateQuoteDiscount({
    required String quoteId,
    required double discountPercentage,
  }) async {
    try {
      final dto = await billingApi.updateQuoteDiscount(
        quoteId,
        {'discountPercentage': discountPercentage},
      );
      final domain = dto.toDomain();
      final idx = _localQuotes.indexWhere((q) => q.id == quoteId);
      if (idx != -1) _localQuotes[idx] = domain;
      return domain;
    } catch (_) {
      // Local fallback
    }

    final idx = _localQuotes.indexWhere((q) => q.id == quoteId);
    if (idx != -1) {
      final current = _localQuotes[idx];
      final subtotal = current.subtotalAmount;
      final discount = subtotal * (discountPercentage / 100.0);
      final updated = current.copyWith(
        discountPercentage: discountPercentage,
        totalAmount: double.parse((subtotal - discount).toStringAsFixed(2)),
      );
      _localQuotes[idx] = updated;
      return updated;
    }
    throw Exception('Quote not found: $quoteId');
  }

  @override
  Future<Quote> approveQuote(String quoteId) async {
    try {
      final dto = await billingApi.approveQuote(quoteId);
      final domain = dto.toDomain();
      final idx = _localQuotes.indexWhere((q) => q.id == quoteId);
      if (idx != -1) _localQuotes[idx] = domain;
      return domain;
    } catch (_) {
      // Local fallback
    }

    final idx = _localQuotes.indexWhere((q) => q.id == quoteId);
    if (idx != -1) {
      final updated = _localQuotes[idx].copyWith(
        status: QuoteStatus.approved,
        approvedAt: DateTime.now(),
      );
      _localQuotes[idx] = updated;
      return updated;
    }
    throw Exception('Quote not found: $quoteId');
  }

  @override
  Future<Quote> cancelQuote(String quoteId) async {
    try {
      final dto = await billingApi.cancelQuote(quoteId);
      final domain = dto.toDomain();
      final idx = _localQuotes.indexWhere((q) => q.id == quoteId);
      if (idx != -1) _localQuotes[idx] = domain;
      return domain;
    } catch (_) {
      // Local fallback
    }

    final idx = _localQuotes.indexWhere((q) => q.id == quoteId);
    if (idx != -1) {
      final updated = _localQuotes[idx].copyWith(status: QuoteStatus.canceled);
      _localQuotes[idx] = updated;
      return updated;
    }
    throw Exception('Quote not found: $quoteId');
  }

  @override
  Future<ElectronicVoucher> registerPayment({
    required String voucherId,
    required double amount,
    required PaymentMethod method,
  }) async {
    try {
      final dto = await billingApi.registerPayment(
        voucherId,
        {'amount': amount, 'method': method.code},
      );
      final domain = dto.toDomain();
      final idx = _localVouchers.indexWhere((v) => v.id == voucherId);
      if (idx != -1) _localVouchers[idx] = domain;
      return domain;
    } catch (_) {
      // Local fallback
    }

    final idx = _localVouchers.indexWhere((v) => v.id == voucherId);
    if (idx != -1) {
      final current = _localVouchers[idx];
      final newTotalPaid = current.totalPaid + amount;
      final newBalance = (current.totalAmount - newTotalPaid).clamp(0.0, current.totalAmount);
      final updatedPayments = [
        ...current.payments,
        VoucherPayment(
          id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
          amount: amount,
          method: method,
          paidAt: DateTime.now(),
        ),
      ];
      final isFullyPaid = newTotalPaid >= current.totalAmount;
      final updated = current.copyWith(
        payments: updatedPayments,
        totalPaid: newTotalPaid,
        balance: newBalance,
        status: isFullyPaid ? VoucherStatus.paid : VoucherStatus.partiallyPaid,
        paidAt: isFullyPaid ? DateTime.now() : null,
      );
      _localVouchers[idx] = updated;
      return updated;
    }
    throw Exception('Voucher not found: $voucherId');
  }

  @override
  Future<void> deletePayment({
    required String voucherId,
    required String paymentId,
  }) async {
    try {
      await billingApi.deletePayment(voucherId, paymentId);
    } catch (_) {
      // Local fallback
    }

    final idx = _localVouchers.indexWhere((v) => v.id == voucherId);
    if (idx != -1) {
      final current = _localVouchers[idx];
      final updatedPayments = current.payments.where((p) => p.id != paymentId).toList();
      final newTotalPaid = updatedPayments.fold(0.0, (acc, p) => acc + p.amount);
      final newBalance = (current.totalAmount - newTotalPaid).clamp(0.0, current.totalAmount);
      _localVouchers[idx] = current.copyWith(
        payments: updatedPayments,
        totalPaid: newTotalPaid,
        balance: newBalance,
        status: newTotalPaid == 0 ? VoucherStatus.pending : VoucherStatus.partiallyPaid,
      );
    }
  }

  @override
  Future<ElectronicVoucher> checkoutDirect({
    required String quoteId,
    required VoucherType type,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    required PaymentMethod method,
    String? branchId,
  }) async {
    try {
      final dto = await billingApi.checkoutDirect({
        'quoteId': quoteId,
        'type': type.code,
        'customerDocumentType': customerDocumentType,
        'customerDocumentNumber': customerDocumentNumber,
        'customerName': customerName,
        'method': method.code,
      });
      final domain = dto.toDomain();
      _localVouchers.insert(0, domain);
      return domain;
    } catch (_) {
      // Local fallback
    }

    final quote = await getQuoteById(quoteId);
    final voucher = ElectronicVoucher.calculateAndCreate(
      id: 'vouch-${DateTime.now().millisecondsSinceEpoch}',
      quoteId: quoteId,
      branchId: branchId ?? quote.branchId,
      workOrderId: quote.workOrderId,
      series: type.defaultSeries,
      number: (_localVouchers.length + 500).toString().padLeft(7, '0'),
      voucherType: type,
      customerDocumentType: customerDocumentType,
      customerDocumentNumber: customerDocumentNumber,
      customerName: customerName,
      items: quote.items.map((i) {
        if (i is VoucherItem) return i;
        final q = i as QuoteItem;
        return VoucherItem.create(
          id: q.id ?? 'it-${DateTime.now().millisecondsSinceEpoch}',
          description: q.name,
          itemType: VoucherItemType.fromCode(q.type),
          quantity: q.quantity,
          unitPrice: q.unitPrice,
        );
      }).toList(),
      paymentMethod: method,
      status: VoucherStatus.paid,
      paidAt: DateTime.now(),
    );
    _localVouchers.insert(0, voucher);
    return voucher;
  }

  @override
  Future<ElectronicVoucher> confirmMercadoPagoCheckout({
    required String quoteId,
    required VoucherType type,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    required String paymentId,
    String? branchId,
  }) async {
    try {
      final dto = await billingApi.confirmMercadoPagoCheckout({
        'quoteId': quoteId,
        'type': type.code,
        'customerDocumentType': customerDocumentType,
        'customerDocumentNumber': customerDocumentNumber,
        'customerName': customerName,
        'paymentId': paymentId,
      });
      final domain = dto.toDomain();
      _localVouchers.insert(0, domain);
      return domain;
    } catch (_) {
      // Local fallback
    }

    return checkoutDirect(
      quoteId: quoteId,
      type: type,
      customerDocumentType: customerDocumentType,
      customerDocumentNumber: customerDocumentNumber,
      customerName: customerName,
      method: PaymentMethod.creditCard,
      branchId: branchId,
    );
  }

  @override
  Future<MercadoPagoPreference> createMercadoPagoPreference({
    required String quoteId,
    VoucherType? type,
    String? customerDocumentType,
    String? customerDocumentNumber,
    String? customerName,
  }) async {
    try {
      final res = await billingApi.createMercadoPagoPreference({
        'quoteId': quoteId,
        'type'?: type?.code,
        'customerDocumentType'?: customerDocumentType,
        'customerDocumentNumber'?: customerDocumentNumber,
        'customerName'?: customerName,
      });
      return MercadoPagoPreferenceDto.fromJson(res).toDomain();
    } catch (_) {
      // Local fallback
    }

    final quote = await getQuoteById(quoteId);
    return MercadoPagoPreference(
      preferenceId: 'pref-${DateTime.now().millisecondsSinceEpoch}',
      initPoint: 'https://www.mercadopago.com.pe/checkout/v1/redirect?pref_id=pref-$quoteId',
      sandboxInitPoint: 'https://sandbox.mercadopago.com.pe/checkout/v1/redirect?pref_id=pref-$quoteId',
      amount: quote.totalAmount,
      currency: 'PEN',
      externalReference: quoteId,
    );
  }
}
