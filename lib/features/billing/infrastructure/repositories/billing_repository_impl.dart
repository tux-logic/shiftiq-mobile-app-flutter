import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/billing_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/dtos/quote_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/dtos/voucher_dto.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingApi billingApi;

  BillingRepositoryImpl({required this.billingApi});

  @override
  Future<List<ElectronicVoucher>> getVouchers({
    required String branchId,
    VoucherType? voucherType,
    VoucherStatus? status,
  }) async {
    final dtos = await billingApi.getVouchers(branchId: branchId);
    var domainList = dtos.map((d) => d.toDomain()).toList();
    if (voucherType != null) {
      domainList =
          domainList.where((v) => v.voucherType == voucherType).toList();
    }
    if (status != null) {
      domainList = domainList.where((v) => v.status == status).toList();
    }
    domainList.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return domainList;
  }

  @override
  Future<ElectronicVoucher> getVoucherById(String id) async {
    final dto = await billingApi.getVoucherById(id);
    return dto.toDomain();
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
    final payload = <String, dynamic>{
      'quoteId': quoteId,
      'type': voucherType == VoucherType.invoice ? 'INVOICE' : 'RECEIPT',
      'customerDocumentType': customerDocumentType.toUpperCase(),
      'customerDocumentNumber': customerDocumentNumber.trim(),
      'customerName': customerName.trim(),
    };

    final dto = await billingApi.emitVoucher(payload);
    return dto.toDomain();
  }

  @override
  Future<ElectronicVoucher> processPayment({
    required String voucherId,
    required PaymentMethod paymentMethod,
  }) async {
    final existing = await getVoucherById(voucherId);
    final amount = existing.balance > 0 ? existing.balance : existing.totalAmount;
    final dto = await billingApi.registerPayment(
      voucherId,
      {
        'amount': amount,
        'method': paymentMethod.code,
      },
    );
    return dto.toDomain();
  }

  @override
  Future<List<Quote>> getMyQuotes() async {
    final dtos = await billingApi.getMyQuotes();
    final list = dtos.map((d) => d.toDomain()).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<Quote>> getQuotes({required String branchId}) async {
    final dtos = await billingApi.getQuotes(branchId: branchId);
    return dtos.map((d) => d.toDomain()).toList();
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
    final quotePayload = <String, dynamic>{
      'branchId': branchId,
    };
    if (workOrderId != null && workOrderId.isNotEmpty) {
      quotePayload['workOrderId'] = workOrderId;
    }
    if (discountPercentage > 0.0) {
      quotePayload['discountPercentage'] = discountPercentage;
    }

    final dto = await billingApi.createQuote(quotePayload);
    return dto.toDomain();
  }

  @override
  Future<Quote> getQuoteById(String quoteId) async {
    final dto = await billingApi.getQuoteById(quoteId);
    return dto.toDomain();
  }

  @override
  Future<Quote> updateQuoteDiscount({
    required String quoteId,
    required double discountPercentage,
  }) async {
    final dto = await billingApi.updateQuoteDiscount(
      quoteId,
      {'discountPercentage': discountPercentage},
    );
    return dto.toDomain();
  }

  @override
  Future<Quote> approveQuote(String quoteId) async {
    final dto = await billingApi.approveQuote(quoteId);
    return dto.toDomain();
  }

  @override
  Future<Quote> cancelQuote(String quoteId) async {
    final dto = await billingApi.cancelQuote(quoteId);
    return dto.toDomain();
  }

  @override
  Future<ElectronicVoucher> registerPayment({
    required String voucherId,
    required double amount,
    required PaymentMethod method,
  }) async {
    final dto = await billingApi.registerPayment(
      voucherId,
      {'amount': amount, 'method': method.code},
    );
    return dto.toDomain();
  }

  @override
  Future<void> deletePayment({
    required String voucherId,
    required String paymentId,
  }) async {
    await billingApi.deletePayment(voucherId, paymentId);
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
    final dto = await billingApi.checkoutDirect({
      'quoteId': quoteId,
      'type': type.code,
      'customerDocumentType': customerDocumentType,
      'customerDocumentNumber': customerDocumentNumber,
      'customerName': customerName,
      'method': method.code,
    });
    return dto.toDomain();
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
    final dto = await billingApi.confirmMercadoPagoCheckout({
      'quoteId': quoteId,
      'type': type.code,
      'customerDocumentType': customerDocumentType,
      'customerDocumentNumber': customerDocumentNumber,
      'customerName': customerName,
      'paymentId': paymentId,
    });
    return dto.toDomain();
  }

  @override
  Future<MercadoPagoPreference> createPaymentSession({
    required String quoteId,
    String provider = 'MERCADO_PAGO',
    VoucherType? type,
    String? customerDocumentType,
    String? customerDocumentNumber,
    String? customerName,
  }) async {
    final Map<String, dynamic> body = {
      'quoteId': quoteId,
      'provider': provider,
    };
    if (type != null) body['type'] = type.code;
    if (customerDocumentType != null) {
      body['customerDocumentType'] = customerDocumentType;
    }
    if (customerDocumentNumber != null) {
      body['customerDocumentNumber'] = customerDocumentNumber;
    }
    if (customerName != null) body['customerName'] = customerName;
    final res = await billingApi.createPaymentSession(body);
    return MercadoPagoPreferenceDto.fromJson(res).toDomain();
  }

  @override
  Future<MercadoPagoPreference> createMercadoPagoPreference({
    required String quoteId,
    VoucherType? type,
    String? customerDocumentType,
    String? customerDocumentNumber,
    String? customerName,
  }) async {
    final Map<String, dynamic> body = {'quoteId': quoteId};
    if (type != null) body['type'] = type.code;
    if (customerDocumentType != null) {
      body['customerDocumentType'] = customerDocumentType;
    }
    if (customerDocumentNumber != null) {
      body['customerDocumentNumber'] = customerDocumentNumber;
    }
    if (customerName != null) body['customerName'] = customerName;
    final res = await billingApi.createMercadoPagoPreference(body);
    return MercadoPagoPreferenceDto.fromJson(res).toDomain();
  }
}
