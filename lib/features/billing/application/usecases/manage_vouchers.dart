import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';

/// Application use case coordinating electronic voucher (Boleta/Factura) emission and payment tracking.
class ManageVouchers {
  final BillingRepository repository;

  const ManageVouchers({required this.repository});

  /// Emits a legal electronic voucher connected to Factos/SUNAT from an approved quotation.
  Future<ElectronicVoucher> emitVoucher({
    required String quoteId,
    required VoucherType voucherType,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    String? customerAddress,
    String? branchId,
    String? workOrderId,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    List<VoucherItem> items = const [],
  }) async {
    if (quoteId.trim().isEmpty) {
      throw ArgumentError('quoteId cannot be empty');
    }
    if (customerName.trim().isEmpty) {
      throw ArgumentError('customerName cannot be empty');
    }

    final cleanDocType = customerDocumentType.trim().toUpperCase();
    final cleanDocNum = customerDocumentNumber.trim();
    final taxDocType = TaxDocumentType.fromCode(cleanDocType);

    // Peruvian SUNAT constraints: Factura strictly requires 11-digit RUC
    if (voucherType == VoucherType.invoice) {
      if (cleanDocType != 'RUC') {
        throw ArgumentError('Factura requires customer document type to be RUC');
      }
      if (!taxDocType.isValid(cleanDocNum)) {
        throw ArgumentError('RUC must contain 11 digits starting with 10 or 20');
      }
    } else if (voucherType == VoucherType.receipt) {
      if (!taxDocType.isValid(cleanDocNum)) {
        throw ArgumentError(
          cleanDocType == 'DNI'
              ? 'DNI must contain exactly 8 digits'
              : 'RUC must contain 11 digits starting with 10 or 20',
        );
      }
    }

    // Validate quote status if available in local/remote repository
    try {
      final quote = await repository.getQuoteById(quoteId.trim());
      if (quote.status != QuoteStatus.approved) {
        throw StateError(
          'Cannot emit electronic voucher for quote in ${quote.status.code} status. Quote must be APPROVED.',
        );
      }
    } catch (e) {
      if (e is StateError) rethrow;
      // Allow fallback if quote was not found locally
    }

    return repository.emitVoucher(
      quoteId: quoteId.trim(),
      branchId: branchId ?? '',
      workOrderId: workOrderId ?? '',
      voucherType: voucherType,
      customerDocumentType: cleanDocType,
      customerDocumentNumber: cleanDocNum,
      customerName: customerName.trim(),
      customerAddress: customerAddress?.trim(),
      paymentMethod: paymentMethod,
      items: items,
    );
  }

  /// Retrieves vouchers emitted for a branch with optional type and status filtering.
  Future<List<ElectronicVoucher>> getVouchers({
    required String branchId,
    VoucherType? voucherType,
    VoucherStatus? status,
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId cannot be empty');
    }
    return repository.getVouchers(
      branchId: branchId.trim(),
      voucherType: voucherType,
      status: status,
    );
  }

  /// Retrieves a specific voucher by ID with complete fiscal and payment breakdown.
  Future<ElectronicVoucher> getVoucherById(String voucherId) async {
    if (voucherId.trim().isEmpty) {
      throw ArgumentError('voucherId cannot be empty');
    }
    return repository.getVoucherById(voucherId.trim());
  }

  /// Registers a partial or total payment on an emitted voucher.
  Future<ElectronicVoucher> registerPayment({
    required String voucherId,
    required double amount,
    required PaymentMethod method,
  }) async {
    if (voucherId.trim().isEmpty) {
      throw ArgumentError('voucherId cannot be empty');
    }
    if (amount <= 0.0) {
      throw ArgumentError('Payment amount must be greater than zero');
    }

    final voucher = await repository.getVoucherById(voucherId.trim());
    if (voucher.status == VoucherStatus.canceled) {
      throw StateError('Cannot register payment on a canceled voucher');
    }
    if (voucher.isPaid) {
      throw StateError('Voucher is already fully paid');
    }

    return repository.registerPayment(
      voucherId: voucherId.trim(),
      amount: amount,
      method: method,
    );
  }

  /// Deletes a payment from a voucher and recalculates status.
  Future<void> deletePayment({
    required String voucherId,
    required String paymentId,
  }) async {
    if (voucherId.trim().isEmpty) {
      throw ArgumentError('voucherId cannot be empty');
    }
    if (paymentId.trim().isEmpty) {
      throw ArgumentError('paymentId cannot be empty');
    }

    final voucher = await repository.getVoucherById(voucherId.trim());
    if (voucher.status == VoucherStatus.canceled) {
      throw StateError('Cannot modify payments on a canceled voucher');
    }

    return repository.deletePayment(
      voucherId: voucherId.trim(),
      paymentId: paymentId.trim(),
    );
  }
}
