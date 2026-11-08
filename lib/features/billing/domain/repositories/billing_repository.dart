import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/electronic_voucher.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/quote.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_type.dart';

abstract class BillingRepository {
  Future<List<ElectronicVoucher>> getVouchers({
    required String branchId,
    VoucherType? voucherType,
    VoucherStatus? status,
  });

  Future<ElectronicVoucher> getVoucherById(String id);

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
  });

  Future<ElectronicVoucher> processPayment({
    required String voucherId,
    required PaymentMethod paymentMethod,
  });

  Future<List<Quote>> getQuotes({required String branchId});

  Future<Quote> createQuote({
    required String branchId,
    String? workOrderId,
    required String customerName,
    required String customerPhone,
    required String vehiclePlate,
    required String vehicleModel,
    required List<VoucherItem> items,
    required DateTime validUntil,
  });
}
