import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/electronic_voucher.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/mercadopago_preference.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/quote.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/models/voucher_type.dart';

abstract class BillingRepository {
  // Quotes Lifecycle
  Future<List<Quote>> getQuotes({required String branchId});

  Future<Quote> getQuoteById(String quoteId);

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
  });

  Future<Quote> updateQuoteDiscount({
    required String quoteId,
    required double discountPercentage,
  });

  Future<Quote> approveQuote(String quoteId);

  Future<Quote> cancelQuote(String quoteId);

  // Vouchers Lifecycle & SUNAT Emission
  Future<List<ElectronicVoucher>> getVouchers({
    required String branchId,
    VoucherType? voucherType,
    VoucherStatus? status,
  });

  Future<ElectronicVoucher> getVoucherById(String id);

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
  });

  Future<ElectronicVoucher> registerPayment({
    required String voucherId,
    required double amount,
    required PaymentMethod method,
  });

  Future<ElectronicVoucher> processPayment({
    required String voucherId,
    required PaymentMethod paymentMethod,
  });

  Future<void> deletePayment({
    required String voucherId,
    required String paymentId,
  });

  // Atomic POS & Gateway Checkouts
  Future<ElectronicVoucher> checkoutDirect({
    required String quoteId,
    required VoucherType type,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    required PaymentMethod method,
    String? branchId,
  });

  Future<ElectronicVoucher> confirmMercadoPagoCheckout({
    required String quoteId,
    required VoucherType type,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    required String paymentId,
    String? branchId,
  });

  Future<MercadoPagoPreference> createMercadoPagoPreference({
    required String quoteId,
    VoucherType? type,
    String? customerDocumentType,
    String? customerDocumentNumber,
    String? customerName,
  });
}
