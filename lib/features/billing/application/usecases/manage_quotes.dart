import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';

/// Application use case coordinating quotation lifecycle for workshop work orders.
class ManageQuotes {
  final BillingRepository repository;

  const ManageQuotes({required this.repository});

  /// Generates a new quotation from a completed work order with optional discount.
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
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId cannot be empty');
    }
    if (discountPercentage < 0.0 || discountPercentage > 100.0) {
      throw ArgumentError('discountPercentage must be between 0 and 100');
    }

    return repository.createQuote(
      branchId: branchId.trim(),
      workOrderId: workOrderId?.trim(),
      discountPercentage: discountPercentage,
      customerName: customerName.trim(),
      customerPhone: customerPhone.trim(),
      vehiclePlate: vehiclePlate.trim(),
      vehicleModel: vehicleModel.trim(),
      items: items,
      validUntil: validUntil,
    );
  }

  /// Retrieves all quotations for a given workshop branch.
  Future<List<Quote>> getQuotes({required String branchId}) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId cannot be empty');
    }
    return repository.getQuotes(branchId: branchId.trim());
  }

  /// Retrieves a quotation with its itemized breakdown.
  Future<Quote> getQuoteById(String quoteId) async {
    if (quoteId.trim().isEmpty) {
      throw ArgumentError('quoteId cannot be empty');
    }
    return repository.getQuoteById(quoteId.trim());
  }

  /// Updates discount percentage for a quote in DRAFT status.
  Future<Quote> updateDiscount({
    required String quoteId,
    required double discountPercentage,
  }) async {
    if (quoteId.trim().isEmpty) {
      throw ArgumentError('quoteId cannot be empty');
    }
    if (discountPercentage < 0.0 || discountPercentage > 100.0) {
      throw ArgumentError('discountPercentage must be between 0 and 100');
    }

    final existing = await repository.getQuoteById(quoteId.trim());
    if (existing.status != QuoteStatus.draft) {
      throw StateError('Cannot modify discount on quote in ${existing.status.code} status');
    }

    return repository.updateQuoteDiscount(
      quoteId: quoteId.trim(),
      discountPercentage: discountPercentage,
    );
  }

  /// Approves a quote (DRAFT -> APPROVED), enabling voucher emission.
  Future<Quote> approveQuote(String quoteId) async {
    if (quoteId.trim().isEmpty) {
      throw ArgumentError('quoteId cannot be empty');
    }

    final existing = await repository.getQuoteById(quoteId.trim());
    if (existing.status == QuoteStatus.approved) {
      return existing;
    }
    if (existing.status == QuoteStatus.canceled) {
      throw StateError('Cannot approve a canceled quote');
    }

    return repository.approveQuote(quoteId.trim());
  }

  /// Cancels a quotation (DRAFT or APPROVED -> CANCELED).
  Future<Quote> cancelQuote(String quoteId) async {
    if (quoteId.trim().isEmpty) {
      throw ArgumentError('quoteId cannot be empty');
    }

    final existing = await repository.getQuoteById(quoteId.trim());
    if (existing.status == QuoteStatus.canceled) {
      return existing;
    }

    return repository.cancelQuote(quoteId.trim());
  }
}
