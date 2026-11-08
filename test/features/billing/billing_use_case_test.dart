import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/commandservices/create_quote_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/commandservices/emit_voucher_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/commandservices/process_payment_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/queryservices/get_quotes_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/queryservices/get_voucher_detail_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/queryservices/get_vouchers_by_branch_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/electronic_voucher.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/quote.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/tax_document.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_type.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/repositories/billing_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/controllers/billing_view_model.dart';

class MockBillingRepository implements BillingRepository {
  final List<ElectronicVoucher> _vouchers = [
    ElectronicVoucher.calculateAndCreate(
      id: 'vouch-01',
      branchId: 'b-01-smp',
      workOrderId: 'wo-101',
      series: 'B001',
      number: '0000482',
      voucherType: VoucherType.boleta,
      customerDocumentType: 'DNI',
      customerDocumentNumber: '45678901',
      customerName: 'Carlos Mendoza',
      items: const [
        VoucherItem(
          id: 'i-1',
          description: 'Diagnóstico OBD-II',
          itemType: VoucherItemType.service,
          quantity: 1,
          unitPrice: 80.0,
          totalPrice: 80.0,
        ),
        VoucherItem(
          id: 'i-2',
          description: 'Pastillas Bosch Delanteras',
          itemType: VoucherItemType.sparePart,
          quantity: 1,
          unitPrice: 100.0,
          totalPrice: 100.0,
        ),
      ],
      paymentMethod: PaymentMethod.cash,
      status: VoucherStatus.paid,
    ),
    ElectronicVoucher.calculateAndCreate(
      id: 'vouch-02',
      branchId: 'b-01-smp',
      workOrderId: 'wo-102',
      series: 'F001',
      number: '0000128',
      voucherType: VoucherType.factura,
      customerDocumentType: 'RUC',
      customerDocumentNumber: '20601893451',
      customerName: 'Transportes Rápidos SAC',
      items: const [
        VoucherItem(
          id: 'i-3',
          description: 'Mantenimiento Preventivo 40k',
          itemType: VoucherItemType.service,
          quantity: 1,
          unitPrice: 500.0,
          totalPrice: 500.0,
        ),
      ],
      paymentMethod: PaymentMethod.bankTransfer,
      status: VoucherStatus.issued,
    ),
  ];

  final List<Quote> _quotes = [
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
      items: const [
        VoucherItem(
          id: 'qi-1',
          description: 'Cambio de Aceite 5W-30',
          itemType: VoucherItemType.service,
          quantity: 1,
          unitPrice: 150.0,
          totalPrice: 150.0,
        ),
      ],
      status: QuoteStatus.approved,
    ),
  ];

  @override
  Future<List<ElectronicVoucher>> getVouchers({
    required String branchId,
    VoucherType? voucherType,
    VoucherStatus? status,
  }) async {
    return _vouchers.where((v) {
      if (v.branchId != branchId && branchId.isNotEmpty) return false;
      if (voucherType != null && v.voucherType != voucherType) return false;
      if (status != null && v.status != status) return false;
      return true;
    }).toList();
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
    required String branchId,
    required String workOrderId,
    required VoucherType voucherType,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    String? customerAddress,
    required PaymentMethod paymentMethod,
    required List<VoucherItem> items,
  }) async {
    final nextNumber = (_vouchers.length + 483).toString().padLeft(7, '0');
    final voucher = ElectronicVoucher.calculateAndCreate(
      id: 'vouch-${DateTime.now().millisecondsSinceEpoch}',
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
          : VoucherStatus.issued,
    );
    _vouchers.insert(0, voucher);
    return voucher;
  }

  @override
  Future<ElectronicVoucher> processPayment({
    required String voucherId,
    required PaymentMethod paymentMethod,
  }) async {
    final idx = _vouchers.indexWhere((v) => v.id == voucherId);
    if (idx == -1) throw Exception('Voucher not found: $voucherId');
    final updated = _vouchers[idx].copyWith(
      status: VoucherStatus.paid,
      paymentMethod: paymentMethod,
      paidAt: DateTime.now(),
    );
    _vouchers[idx] = updated;
    return updated;
  }

  @override
  Future<List<Quote>> getQuotes({required String branchId}) async {
    return _quotes.where((q) => q.branchId == branchId || branchId.isEmpty).toList();
  }

  @override
  Future<Quote> createQuote({
    required String branchId,
    String? workOrderId,
    required String customerName,
    required String customerPhone,
    required String vehiclePlate,
    required String vehicleModel,
    required List<VoucherItem> items,
    required DateTime validUntil,
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
      validUntil: validUntil,
    );
    _quotes.insert(0, quote);
    return quote;
  }
}

void main() {
  group('Hito 7: Billing, Quotes & SUNAT Electronic Vouchers B2B', () {
    late MockBillingRepository repository;
    late GetVouchersByBranchQueryService getVouchersQuery;
    late GetVoucherDetailQueryService getVoucherDetailQuery;
    late GetQuotesQueryService getQuotesQuery;
    late EmitVoucherCommandService emitVoucherCommand;
    late ProcessPaymentCommandService processPaymentCommand;
    late CreateQuoteCommandService createQuoteCommand;

    setUp(() {
      repository = MockBillingRepository();
      getVouchersQuery = GetVouchersByBranchQueryService(billingRepository: repository);
      getVoucherDetailQuery = GetVoucherDetailQueryService(billingRepository: repository);
      getQuotesQuery = GetQuotesQueryService(billingRepository: repository);
      emitVoucherCommand = EmitVoucherCommandService(billingRepository: repository);
      processPaymentCommand = ProcessPaymentCommandService(billingRepository: repository);
      createQuoteCommand = CreateQuoteCommandService(billingRepository: repository);
    });

    test('1. GetVouchersByBranchQueryService returns all vouchers for branch', () async {
      final vouchers = await getVouchersQuery.execute(branchId: 'b-01-smp');
      expect(vouchers.length, equals(2));
      expect(vouchers.first.series, equals('B001'));
      expect(vouchers.first.fullCode, equals('B001-0000482'));
    });

    test('2. Query filters vouchers by VoucherType and VoucherStatus', () async {
      final boletas = await getVouchersQuery.execute(
        branchId: 'b-01-smp',
        voucherType: VoucherType.boleta,
      );
      expect(boletas.length, equals(1));
      expect(boletas.first.customerName, equals('Carlos Mendoza'));

      final facturas = await getVouchersQuery.execute(
        branchId: 'b-01-smp',
        voucherType: VoucherType.factura,
      );
      expect(facturas.length, equals(1));
      expect(facturas.first.customerDocumentNumber, equals('20601893451'));

      final paidVouchers = await getVouchersQuery.execute(
        branchId: 'b-01-smp',
        status: VoucherStatus.paid,
      );
      expect(paidVouchers.length, equals(1));
      expect(paidVouchers.first.isPaid, isTrue);
    });

    test('3. EmitVoucherCommandService calculates Peruvian 18% IGV and Subtotal accurately', () async {
      final emitted = await emitVoucherCommand.execute(
        branchId: 'b-01-smp',
        workOrderId: 'wo-103',
        voucherType: VoucherType.boleta,
        customerDocumentType: 'DNI',
        customerDocumentNumber: '72345678',
        customerName: 'Juan Pérez',
        paymentMethod: PaymentMethod.cash,
        items: const [
          VoucherItem(
            id: 'it-1',
            description: 'Servicio de Frenos',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 118.0,
            totalPrice: 118.0,
          ),
        ],
      );

      // Total = 118.00 -> Subtotal = 100.00, IGV = 18.00
      expect(emitted.total, equals(118.0));
      expect(emitted.subtotal, equals(100.0));
      expect(emitted.igv, equals(18.0));
      expect(emitted.series, equals('B001'));
      expect(emitted.sunatHash, isNotEmpty);
      expect(emitted.qrData, contains('20601234567|BOLETA|B001'));
    });

    test('4. TaxDocument and EmitVoucherCommandService validate DNI and RUC constraints', () async {
      // Valid DNI
      const validDni = TaxDocument(type: 'DNI', number: '45678901');
      expect(validDni.isValid, isTrue);
      expect(validDni.validate(), isNull);

      // Invalid DNI length
      const invalidDni = TaxDocument(type: 'DNI', number: '1234');
      expect(invalidDni.isValid, isFalse);
      expect(invalidDni.validate(), contains('8 dígitos'));

      // Valid RUC
      const validRuc = TaxDocument(type: 'RUC', number: '20601893451');
      expect(validRuc.isValid, isTrue);
      expect(validRuc.validate(), isNull);

      // Invalid RUC not starting with 10 or 20
      const invalidRuc = TaxDocument(type: 'RUC', number: '15601893451');
      expect(invalidRuc.isValid, isFalse);
      expect(invalidRuc.validate(), contains('empezar con 10 o 20'));

      // Factura with DNI should throw ArgumentError
      expect(
        () => emitVoucherCommand.execute(
          branchId: 'b-01-smp',
          workOrderId: 'wo-104',
          voucherType: VoucherType.factura,
          customerDocumentType: 'DNI',
          customerDocumentNumber: '45678901',
          customerName: 'Empresa Falsa',
          paymentMethod: PaymentMethod.bankTransfer,
          items: const [
            VoucherItem(
              id: 'it-1',
              description: 'Servicio',
              itemType: VoucherItemType.service,
              quantity: 1,
              unitPrice: 100.0,
              totalPrice: 100.0,
            ),
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('5. ProcessPaymentCommandService transitions voucher from issued to paid', () async {
      final initial = await getVoucherDetailQuery.execute('vouch-02');
      expect(initial.status, equals(VoucherStatus.issued));
      expect(initial.isPaid, isFalse);

      final paid = await processPaymentCommand.execute(
        voucherId: 'vouch-02',
        paymentMethod: PaymentMethod.posCard,
      );
      expect(paid.status, equals(VoucherStatus.paid));
      expect(paid.paymentMethod, equals(PaymentMethod.posCard));
      expect(paid.paidAt, isNotNull);
    });

    test('6. CreateQuoteCommandService creates valid Quote aggregate', () async {
      final quote = await createQuoteCommand.execute(
        branchId: 'b-01-smp',
        customerName: 'Mario Salcedo',
        customerPhone: '+51 955 443 322',
        vehiclePlate: 'D2A-789',
        vehicleModel: 'Toyota Yaris 2022',
        validUntil: DateTime.now().add(const Duration(days: 15)),
        items: const [
          VoucherItem(
            id: 'it-10',
            description: 'Cambio de bujías de Iridio',
            itemType: VoucherItemType.service,
            quantity: 4,
            unitPrice: 45.0,
            totalPrice: 180.0,
          ),
        ],
      );

      expect(quote.quoteNumber, startsWith('COT-2026-'));
      expect(quote.customerName, equals('Mario Salcedo'));
      expect(quote.total, equals(180.0));
      expect(quote.status, equals(QuoteStatus.draft));
    });

    test('7. BillingViewModel handles data load, filters, emission, and daily metrics', () async {
      final viewModel = BillingViewModel(
        getVouchersQuery: getVouchersQuery,
        getVoucherDetailQuery: getVoucherDetailQuery,
        getQuotesQuery: getQuotesQuery,
        emitVoucherCommand: emitVoucherCommand,
        processPaymentCommand: processPaymentCommand,
        createQuoteCommand: createQuoteCommand,
      );

      await viewModel.loadBillingData('b-01-smp');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.vouchers.length, equals(2));
      expect(viewModel.quotes.length, equals(1));
      expect(viewModel.pendingPaymentsCount, equals(1)); // vouch-02 is issued

      // Filter by Factura
      await viewModel.filterByType(VoucherType.factura, 'b-01-smp');
      expect(viewModel.vouchers.length, equals(1));
      expect(viewModel.vouchers.first.voucherType, equals(VoucherType.factura));

      // Reset filter
      await viewModel.filterByType(null, 'b-01-smp');
      expect(viewModel.vouchers.length, equals(2));

      // Emit new Boleta
      final emitted = await viewModel.emitVoucher(
        branchId: 'b-01-smp',
        workOrderId: 'wo-105',
        voucherType: VoucherType.boleta,
        customerDocumentType: 'DNI',
        customerDocumentNumber: '87654321',
        customerName: 'Lucía Fernández',
        paymentMethod: PaymentMethod.cash,
        items: const [
          VoucherItem(
            id: 'it-5',
            description: 'Alineación y Balanceo',
            itemType: VoucherItemType.service,
            quantity: 1,
            unitPrice: 120.0,
            totalPrice: 120.0,
          ),
        ],
      );

      expect(emitted, isNotNull);
      expect(viewModel.vouchers.length, equals(3));
      expect(viewModel.vouchers.first.customerName, equals('Lucía Fernández'));
    });
  });
}
