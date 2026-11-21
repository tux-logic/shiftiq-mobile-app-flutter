import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';

/// Application use case coordinating point-of-sale (POS) atomic checkouts and Mercado Pago gateway integrations.
class ManageCheckouts {
  final BillingRepository repository;

  const ManageCheckouts({required this.repository});

  /// Executes an atomic direct checkout: emits legal voucher and registers full payment in one transaction.
  Future<ElectronicVoucher> checkoutDirect({
    required String quoteId,
    required VoucherType type,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    required PaymentMethod method,
    String? branchId,
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

    // Validate SUNAT fiscal constraints
    if (type == VoucherType.invoice) {
      if (cleanDocType != 'RUC') {
        throw ArgumentError('Factura checkout requires customer document type to be RUC');
      }
      if (!taxDocType.isValid(cleanDocNum)) {
        throw ArgumentError('RUC must contain 11 digits starting with 10 or 20');
      }
    } else if (type == VoucherType.receipt) {
      if (!taxDocType.isValid(cleanDocNum)) {
        throw ArgumentError(
          cleanDocType == 'DNI'
              ? 'DNI must contain exactly 8 digits'
              : 'RUC must contain 11 digits starting with 10 or 20',
        );
      }
    }

    // Verify quote state is APPROVED
    try {
      final quote = await repository.getQuoteById(quoteId.trim());
      if (quote.status != QuoteStatus.approved) {
        throw StateError(
          'Cannot checkout quote in ${quote.status.code} status. Quote must be APPROVED.',
        );
      }
    } catch (e) {
      if (e is StateError) rethrow;
      // Allow fallback if quote is managed remotely
    }

    return repository.checkoutDirect(
      quoteId: quoteId.trim(),
      type: type,
      customerDocumentType: cleanDocType,
      customerDocumentNumber: cleanDocNum,
      customerName: customerName.trim(),
      method: method,
      branchId: branchId,
    );
  }

  /// Generates a Mercado Pago Checkout Pro payment preference for an approved quotation.
  Future<MercadoPagoPreference> createMercadoPagoPreference({
    required String quoteId,
    VoucherType? type,
    String? customerDocumentType,
    String? customerDocumentNumber,
    String? customerName,
  }) async {
    if (quoteId.trim().isEmpty) {
      throw ArgumentError('quoteId cannot be empty');
    }

    if (type == VoucherType.invoice && customerDocumentType != null) {
      final cleanDocType = customerDocumentType.trim().toUpperCase();
      if (cleanDocType != 'RUC') {
        throw ArgumentError('Factura requires customer document type to be RUC');
      }
      if (customerDocumentNumber != null) {
        final cleanDocNum = customerDocumentNumber.trim();
        if (!TaxDocumentType.ruc.isValid(cleanDocNum)) {
          throw ArgumentError('RUC must contain 11 digits starting with 10 or 20');
        }
      }
    }

    return repository.createMercadoPagoPreference(
      quoteId: quoteId.trim(),
      type: type,
      customerDocumentType: customerDocumentType?.trim().toUpperCase(),
      customerDocumentNumber: customerDocumentNumber?.trim(),
      customerName: customerName?.trim(),
    );
  }

  /// Confirms a successful Mercado Pago checkout callback, emitting the legal voucher with verified payment.
  Future<ElectronicVoucher> confirmMercadoPagoCheckout({
    required String quoteId,
    required VoucherType type,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    required String paymentId,
    String? branchId,
  }) async {
    if (quoteId.trim().isEmpty) {
      throw ArgumentError('quoteId cannot be empty');
    }
    if (paymentId.trim().isEmpty) {
      throw ArgumentError('paymentId from Mercado Pago is required');
    }
    if (customerName.trim().isEmpty) {
      throw ArgumentError('customerName cannot be empty');
    }

    final cleanDocType = customerDocumentType.trim().toUpperCase();
    final cleanDocNum = customerDocumentNumber.trim();

    return repository.confirmMercadoPagoCheckout(
      quoteId: quoteId.trim(),
      type: type,
      customerDocumentType: cleanDocType,
      customerDocumentNumber: cleanDocNum,
      customerName: customerName.trim(),
      paymentId: paymentId.trim(),
      branchId: branchId,
    );
  }
}
