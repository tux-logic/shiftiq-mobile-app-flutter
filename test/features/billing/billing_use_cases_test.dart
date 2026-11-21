import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_checkouts.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_quotes.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_vouchers.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/controllers/billing_view_model.dart';

class MockBillingRepository implements BillingRepository {
  final List<ElectronicVoucher> _vouchers = [];
  final List<Quote> _quotes = [];

  MockBillingRepository() {
    _seedInitialData();
  }

  void _seedInitialData() {
    _vouchers.addAll([
      ElectronicVoucher.calculateAndCreate(
        id: 'vouch-01-boleta',
        quoteId: 'quote-01',
        branchId: 'b-01-smp',
        workOrderId: 'wo-101',
        series: 'B001',
        number: '0000482',
        voucherType: VoucherType.receipt,
        customerDocumentType: 'DNI',
        customerDocumentNumber: '45678901',
        customerName: 'Carlos Mendoza',
        customerAddress: 'Av. Universitaria 1240, Lima',
        items: const [
          VoucherItem(
            id: 'item-1',
            description: 'OBD-II Computerized Diagnosis',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 80.0,
            totalPrice: 80.0,
          ),
          VoucherItem(
            id: 'item-2',
            description: 'Brake Pads Replacement Labor',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 120.0,
            totalPrice: 120.0,
          ),
        ],
        paymentMethod: PaymentMethod.cash,
        status: VoucherStatus.paid,
        issuedAt: DateTime.now().subtract(const Duration(hours: 4)),
        paidAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ElectronicVoucher.calculateAndCreate(
        id: 'vouch-02-factura',
        quoteId: 'quote-02',
        branchId: 'b-01-smp',
        workOrderId: 'wo-102',
        series: 'F001',
        number: '0000128',
        voucherType: VoucherType.invoice,
        customerDocumentType: 'RUC',
        customerDocumentNumber: '20601893451',
        customerName: 'Transportes Rapidos Lima S.A.C.',
        customerAddress: 'Calle Los Hornos 450, SMP',
        items: const [
          VoucherItem(
            id: 'item-201',
            description: 'Fleet Preventive Maintenance',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 450.0,
            totalPrice: 450.0,
          ),
        ],
        paymentMethod: PaymentMethod.bankTransfer,
        status: VoucherStatus.emitted,
        issuedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    _quotes.addAll([
      Quote.calculateAndCreate(
        id: 'quote-01',
        branchId: 'b-01-smp',
        workOrderId: 'wo-101',
        quoteNumber: 'COT-2026-0042',
        customerName: 'Carlos Mendoza',
        customerPhone: '+51 987 654 321',
        vehiclePlate: 'ABC-123',
        vehicleModel: 'Toyota Hilux 2021',
        validUntil: DateTime.now().add(const Duration(days: 7)),
        status: QuoteStatus.approved,
        items: const [
          QuoteItem(
            id: 'qi-1',
            type: 'SERVICE',
            name: 'OBD-II Computerized Diagnosis',
            quantity: 1,
            unitPrice: 80.0,
            total: 80.0,
          ),
          QuoteItem(
            id: 'qi-2',
            type: 'SERVICE',
            name: 'Brake Pads Replacement Labor',
            quantity: 1,
            unitPrice: 120.0,
            total: 120.0,
          ),
        ],
      ),
      Quote.calculateAndCreate(
        id: 'quote-02',
        branchId: 'b-01-smp',
        workOrderId: 'wo-102',
        quoteNumber: 'COT-2026-0043',
        customerName: 'Transportes Rapidos Lima S.A.C.',
        customerPhone: '+51 999 888 777',
        vehiclePlate: 'XYZ-789',
        vehicleModel: 'Hyundai H1 2020',
        validUntil: DateTime.now().add(const Duration(days: 7)),
        status: QuoteStatus.draft,
        items: const [
          QuoteItem(
            id: 'qi-201',
            type: 'SERVICE',
            name: 'Fleet Preventive Maintenance',
            quantity: 1,
            unitPrice: 450.0,
            total: 450.0,
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
    var list = _vouchers
        .where((v) => v.branchId == branchId || branchId.isEmpty)
        .toList();

    if (voucherType != null) {
      list = list.where((v) => v.type == voucherType).toList();
    }
    if (status != null) {
      list = list.where((v) => v.status == status).toList();
    }
    list.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return list;
  }

  @override
  Future<ElectronicVoucher> getVoucherById(String id) async {
    return _vouchers.firstWhere(
      (v) => v.id == id,
      orElse: () => throw Exception('Voucher not found: $id'),
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
    final nextNumber = (_vouchers.length + 483).toString().padLeft(7, '0');
    final voucher = ElectronicVoucher.calculateAndCreate(
      id: 'vouch-${DateTime.now().millisecondsSinceEpoch}',
      quoteId: quoteId.isNotEmpty ? quoteId : null,
      branchId: branchId,
      workOrderId: workOrderId,
      series: voucherType.defaultSeries,
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
    _vouchers.insert(0, voucher);
    return voucher;
  }

  @override
  Future<ElectronicVoucher> processPayment({
    required String voucherId,
    required PaymentMethod paymentMethod,
  }) async {
    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index != -1) {
      final current = _vouchers[index];
      final paidVoucher = current.copyWith(
        status: VoucherStatus.paid,
        paymentMethod: paymentMethod,
        totalPaid: current.totalAmount,
        balance: 0.0,
        paidAt: DateTime.now(),
      );
      _vouchers[index] = paidVoucher;
      return paidVoucher;
    }
    throw Exception('Voucher not found: $voucherId');
  }

  @override
  Future<List<Quote>> getQuotes({required String branchId}) async {
    return _quotes.where((q) => q.branchId == branchId || branchId.isEmpty).toList();
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
    final quoteNumber = 'COT-2026-${(_quotes.length + 43).toString().padLeft(4, '0')}';
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
    );
    _quotes.insert(0, quote);
    return quote;
  }

  @override
  Future<Quote> getQuoteById(String quoteId) async {
    return _quotes.firstWhere(
      (q) => q.id == quoteId,
      orElse: () => throw Exception('Quote not found: $quoteId'),
    );
  }

  @override
  Future<Quote> updateQuoteDiscount({
    required String quoteId,
    required double discountPercentage,
  }) async {
    final idx = _quotes.indexWhere((q) => q.id == quoteId);
    if (idx != -1) {
      final current = _quotes[idx];
      final subtotal = current.subtotalAmount;
      final discount = subtotal * (discountPercentage / 100.0);
      final updated = current.copyWith(
        discountPercentage: discountPercentage,
        totalAmount: double.parse((subtotal - discount).toStringAsFixed(2)),
      );
      _quotes[idx] = updated;
      return updated;
    }
    throw Exception('Quote not found: $quoteId');
  }

  @override
  Future<Quote> approveQuote(String quoteId) async {
    final idx = _quotes.indexWhere((q) => q.id == quoteId);
    if (idx != -1) {
      final updated = _quotes[idx].copyWith(
        status: QuoteStatus.approved,
        approvedAt: DateTime.now(),
      );
      _quotes[idx] = updated;
      return updated;
    }
    throw Exception('Quote not found: $quoteId');
  }

  @override
  Future<Quote> cancelQuote(String quoteId) async {
    final idx = _quotes.indexWhere((q) => q.id == quoteId);
    if (idx != -1) {
      final updated = _quotes[idx].copyWith(status: QuoteStatus.canceled);
      _quotes[idx] = updated;
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
    final idx = _vouchers.indexWhere((v) => v.id == voucherId);
    if (idx != -1) {
      final current = _vouchers[idx];
      final newTotalPaid = current.totalPaid + amount;
      final newBalance = (current.totalAmount - newTotalPaid).clamp(0.0, current.totalAmount);
      final isFullyPaid = newTotalPaid >= current.totalAmount;
      final updated = current.copyWith(
        payments: [
          ...current.payments,
          VoucherPayment(
            id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
            amount: amount,
            method: method,
            paidAt: DateTime.now(),
          ),
        ],
        totalPaid: newTotalPaid,
        balance: newBalance,
        status: isFullyPaid ? VoucherStatus.paid : VoucherStatus.partiallyPaid,
        paidAt: isFullyPaid ? DateTime.now() : null,
      );
      _vouchers[idx] = updated;
      return updated;
    }
    throw Exception('Voucher not found: $voucherId');
  }

  @override
  Future<void> deletePayment({
    required String voucherId,
    required String paymentId,
  }) async {
    final idx = _vouchers.indexWhere((v) => v.id == voucherId);
    if (idx != -1) {
      final current = _vouchers[idx];
      final updatedPayments = current.payments.where((p) => p.id != paymentId).toList();
      final newTotalPaid = updatedPayments.fold(0.0, (acc, p) => acc + p.amount);
      final newBalance = (current.totalAmount - newTotalPaid).clamp(0.0, current.totalAmount);
      _vouchers[idx] = current.copyWith(
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
    final quote = await getQuoteById(quoteId);
    final voucher = ElectronicVoucher.calculateAndCreate(
      id: 'vouch-${DateTime.now().millisecondsSinceEpoch}',
      quoteId: quoteId,
      branchId: branchId ?? quote.branchId,
      workOrderId: quote.workOrderId,
      series: type.defaultSeries,
      number: (_vouchers.length + 500).toString().padLeft(7, '0'),
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
    _vouchers.insert(0, voucher);
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

void main() {
  group('Billing Bounded Context - Clean Architecture Unit Tests', () {
    late MockBillingRepository repository;
    late ManageQuotes manageQuotes;
    late ManageVouchers manageVouchers;
    late ManageCheckouts manageCheckouts;
    late BillingViewModel viewModel;

    setUp(() {
      repository = MockBillingRepository();
      manageQuotes = ManageQuotes(repository: repository);
      manageVouchers = ManageVouchers(repository: repository);
      manageCheckouts = ManageCheckouts(repository: repository);
      viewModel = BillingViewModel(
        manageQuotes: manageQuotes,
        manageVouchers: manageVouchers,
        manageCheckouts: manageCheckouts,
      );
    });

    group('ManageQuotes Use Case', () {
      test('validates inputs and creates quote aggregate with accurate calculations', () async {
        expect(
          () => manageQuotes.createQuote(branchId: '', workOrderId: 'wo-1'),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => manageQuotes.createQuote(
            branchId: 'b-01',
            workOrderId: 'wo-1',
            discountPercentage: 105.0,
          ),
          throwsA(isA<ArgumentError>()),
        );

        final quote = await manageQuotes.createQuote(
          branchId: 'b-01-smp',
          workOrderId: 'wo-999',
          customerName: 'Lucia Ramos',
          customerPhone: '+51 911 222 333',
          vehiclePlate: 'PER-456',
          vehicleModel: 'Kia Rio 2019',
          items: const [
            QuoteItem(
              id: 'it-1',
              type: 'SERVICE',
              name: 'Engine Oil Change',
              quantity: 1,
              unitPrice: 100.0,
              total: 100.0,
            ),
            QuoteItem(
              id: 'it-2',
              type: 'PRODUCT',
              name: 'Castrol 10W-40',
              quantity: 1,
              unitPrice: 100.0,
              total: 100.0,
            ),
          ],
          discountPercentage: 10.0,
        );

        expect(quote.id, isNotEmpty);
        expect(quote.subtotalAmount, equals(200.0));
        expect(quote.discountPercentage, equals(10.0));
        expect(quote.totalAmount, equals(180.0));
        expect(quote.status, equals(QuoteStatus.draft));
        expect(quote.isDraft, isTrue);
      });

      test('queries quotes by branch and by identifier', () async {
        final list = await manageQuotes.getQuotes(branchId: 'b-01-smp');
        expect(list.length, greaterThanOrEqualTo(2));

        final quote = await manageQuotes.getQuoteById('quote-01');
        expect(quote.id, equals('quote-01'));
        expect(quote.customerName, equals('Carlos Mendoza'));
      });

      test('updates discount on draft quote and recalculates totalAmount', () async {
        final updated = await manageQuotes.updateDiscount(
          quoteId: 'quote-02',
          discountPercentage: 20.0,
        );
        expect(updated.discountPercentage, equals(20.0));
        expect(updated.totalAmount, equals(360.0)); // 450 - 20% = 360
      });

      test('rejects discount update on approved quote', () async {
        expect(
          () => manageQuotes.updateDiscount(
            quoteId: 'quote-01',
            discountPercentage: 15.0,
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('approves draft quote and enables billing lifecycle', () async {
        final approved = await manageQuotes.approveQuote('quote-02');
        expect(approved.status, equals(QuoteStatus.approved));
        expect(approved.isApproved, isTrue);
        expect(approved.approvedAt, isNotNull);
      });

      test('cancels quote and rejects transition if already canceled', () async {
        final canceled = await manageQuotes.cancelQuote('quote-01');
        expect(canceled.status, equals(QuoteStatus.canceled));
        expect(canceled.isCanceled, isTrue);

        expect(
          () => manageQuotes.approveQuote('quote-01'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('ManageVouchers Use Case', () {
      test('enforces Peruvian SUNAT DNI and RUC validation constraints', () async {
        // Factura requires RUC
        expect(
          () => manageVouchers.emitVoucher(
            quoteId: 'quote-01',
            voucherType: VoucherType.invoice,
            customerDocumentType: 'DNI',
            customerDocumentNumber: '45678901',
            customerName: 'Empresa Demo SAC',
          ),
          throwsA(isA<ArgumentError>()),
        );

        // Factura with invalid RUC (not starting with 10 or 20)
        expect(
          () => manageVouchers.emitVoucher(
            quoteId: 'quote-01',
            voucherType: VoucherType.invoice,
            customerDocumentType: 'RUC',
            customerDocumentNumber: '15601893451',
            customerName: 'Empresa Demo SAC',
          ),
          throwsA(isA<ArgumentError>()),
        );

        // Boleta with invalid DNI length
        expect(
          () => manageVouchers.emitVoucher(
            quoteId: 'quote-01',
            voucherType: VoucherType.receipt,
            customerDocumentType: 'DNI',
            customerDocumentNumber: '1234',
            customerName: 'Juan Perez',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('requires quote to be in APPROVED status before voucher emission', () async {
        expect(
          () => manageVouchers.emitVoucher(
            quoteId: 'quote-02', // quote-02 is in DRAFT
            voucherType: VoucherType.receipt,
            customerDocumentType: 'DNI',
            customerDocumentNumber: '72345678',
            customerName: 'Juan Perez',
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('emits valid voucher with accurate 18% IGV and SUNAT QR data', () async {
        final voucher = await manageVouchers.emitVoucher(
          quoteId: 'quote-01',
          branchId: 'b-01-smp',
          workOrderId: 'wo-101',
          voucherType: VoucherType.receipt,
          customerDocumentType: 'DNI',
          customerDocumentNumber: '72345678',
          customerName: 'Juan Perez',
          paymentMethod: PaymentMethod.cash,
          items: const [
            VoucherItem(
              id: 'it-1',
              description: 'Pastillas de Freno',
              itemType: VoucherItemType.sparePart,
              quantity: 1,
              unitPrice: 118.0,
              totalPrice: 118.0,
            ),
          ],
        );

        expect(voucher.id, isNotEmpty);
        expect(voucher.total, equals(118.0));
        expect(voucher.subtotal, equals(100.0));
        expect(voucher.igv, equals(18.0));
        expect(voucher.series, equals('B001'));
        expect(voucher.qrData, contains('20601234567|BOLETA|B001'));
        expect(voucher.isPaid, isTrue);
      });

      test('queries vouchers by branch, type, and payment status', () async {
        final all = await manageVouchers.getVouchers(branchId: 'b-01-smp');
        expect(all.length, greaterThanOrEqualTo(2));

        final facturas = await manageVouchers.getVouchers(
          branchId: 'b-01-smp',
          voucherType: VoucherType.invoice,
        );
        expect(facturas.every((v) => v.type == VoucherType.invoice), isTrue);

        final pending = await manageVouchers.getVouchers(
          branchId: 'b-01-smp',
          status: VoucherStatus.emitted,
        );
        expect(pending.every((v) => v.status == VoucherStatus.emitted), isTrue);
      });

      test('registers partial payment and full payment transition', () async {
        // Register partial payment on vouch-02-factura (total is 450)
        final partial = await manageVouchers.registerPayment(
          voucherId: 'vouch-02-factura',
          amount: 200.0,
          method: PaymentMethod.bankTransfer,
        );
        expect(partial.totalPaid, equals(200.0));
        expect(partial.balance, equals(250.0));
        expect(partial.status, equals(VoucherStatus.partiallyPaid));

        // Complete remaining payment
        final fullyPaid = await manageVouchers.registerPayment(
          voucherId: 'vouch-02-factura',
          amount: 250.0,
          method: PaymentMethod.bankTransfer,
        );
        expect(fullyPaid.totalPaid, equals(450.0));
        expect(fullyPaid.balance, equals(0.0));
        expect(fullyPaid.status, equals(VoucherStatus.paid));
        expect(fullyPaid.isPaid, isTrue);
      });

      test('rejects payment on already paid voucher', () async {
        expect(
          () => manageVouchers.registerPayment(
            voucherId: 'vouch-01-boleta',
            amount: 50.0,
            method: PaymentMethod.cash,
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('deletes payment and restores voucher balance', () async {
        // Create a voucher and add payment
        final voucher = await manageVouchers.registerPayment(
          voucherId: 'vouch-02-factura',
          amount: 100.0,
          method: PaymentMethod.bankTransfer,
        );
        final paymentId = voucher.payments.last.id;

        await manageVouchers.deletePayment(
          voucherId: 'vouch-02-factura',
          paymentId: paymentId,
        );

        final updated = await manageVouchers.getVoucherById('vouch-02-factura');
        expect(updated.payments.any((p) => p.id == paymentId), isFalse);
      });
    });

    group('ManageCheckouts Use Case', () {
      test('executes atomic POS checkout directly with 100% payment', () async {
        final voucher = await manageCheckouts.checkoutDirect(
          quoteId: 'quote-01',
          type: VoucherType.receipt,
          customerDocumentType: 'DNI',
          customerDocumentNumber: '48765432',
          customerName: 'Maria Fernandez',
          method: PaymentMethod.cash,
          branchId: 'b-01-smp',
        );

        expect(voucher.id, isNotEmpty);
        expect(voucher.quoteId, equals('quote-01'));
        expect(voucher.status, equals(VoucherStatus.paid));
        expect(voucher.isPaid, isTrue);
        expect(voucher.totalPaid, equals(voucher.totalAmount));
      });

      test('creates Mercado Pago Checkout Pro preference from approved quote', () async {
        final pref = await manageCheckouts.createMercadoPagoPreference(
          quoteId: 'quote-01',
          type: VoucherType.receipt,
          customerDocumentType: 'DNI',
          customerDocumentNumber: '48765432',
          customerName: 'Maria Fernandez',
        );

        expect(pref.preferenceId, isNotEmpty);
        expect(pref.initPoint, contains('mercadopago.com'));
        expect(pref.amount, equals(200.0));
        expect(pref.currency, equals('PEN'));
        expect(pref.externalReference, equals('quote-01'));
      });

      test('confirms Mercado Pago payment callback post-redirection', () async {
        final voucher = await manageCheckouts.confirmMercadoPagoCheckout(
          quoteId: 'quote-01',
          type: VoucherType.receipt,
          customerDocumentType: 'DNI',
          customerDocumentNumber: '48765432',
          customerName: 'Maria Fernandez',
          paymentId: '98765432101',
          branchId: 'b-01-smp',
        );

        expect(voucher.id, isNotEmpty);
        expect(voucher.status, equals(VoucherStatus.paid));
        expect(voucher.isPaid, isTrue);
      });
    });

    group('BillingViewModel Presentation Integration', () {
      test('loads vouchers and quotes, and calculates KPI metrics', () async {
        await viewModel.loadBillingData('b-01-smp');

        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.vouchers.length, greaterThanOrEqualTo(2));
        expect(viewModel.quotes.length, greaterThanOrEqualTo(2));

        expect(viewModel.totalBilledToday, greaterThan(0.0));
        expect(viewModel.pendingPaymentsCount, greaterThanOrEqualTo(1));
      });

      test('filters vouchers by type and status in ViewModel', () async {
        await viewModel.filterByType(VoucherType.invoice, 'b-01-smp');
        expect(viewModel.selectedTypeFilter, equals(VoucherType.invoice));
        expect(viewModel.vouchers.every((v) => v.type == VoucherType.invoice), isTrue);

        await viewModel.filterByStatus(VoucherStatus.emitted, 'b-01-smp');
        expect(viewModel.selectedStatusFilter, equals(VoucherStatus.emitted));
        expect(viewModel.vouchers.every((v) => v.status == VoucherStatus.emitted), isTrue);
      });

      test('handles full presentation checkout flow via ViewModel', () async {
        final voucher = await viewModel.checkoutDirect(
          quoteId: 'quote-01',
          type: VoucherType.receipt,
          customerDocumentType: 'DNI',
          customerDocumentNumber: '48765432',
          customerName: 'Maria Fernandez',
          method: PaymentMethod.cash,
          branchId: 'b-01-smp',
        );

        expect(voucher, isNotNull);
        expect(viewModel.selectedVoucher?.id, equals(voucher!.id));
        expect(viewModel.selectedVoucher?.isPaid, isTrue);
      });
    });
  });
}
