import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_checkouts.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_quotes.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_vouchers.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';

class BillingViewModel extends ChangeNotifier {
  final ManageQuotes manageQuotes;
  final ManageVouchers manageVouchers;
  final ManageCheckouts manageCheckouts;

  BillingViewModel({
    required this.manageQuotes,
    required this.manageVouchers,
    required this.manageCheckouts,
  });

  bool _isLoading = false;
  String? _errorMessage;
  List<ElectronicVoucher> _vouchers = [];
  List<Quote> _quotes = [];
  ElectronicVoucher? _selectedVoucher;
  Quote? _selectedQuote;
  VoucherType? _selectedTypeFilter;
  VoucherStatus? _selectedStatusFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ElectronicVoucher> get vouchers => _vouchers;
  List<Quote> get quotes => _quotes;
  ElectronicVoucher? get selectedVoucher => _selectedVoucher;
  Quote? get selectedQuote => _selectedQuote;
  VoucherType? get selectedTypeFilter => _selectedTypeFilter;
  VoucherStatus? get selectedStatusFilter => _selectedStatusFilter;

  double get totalBilledToday => _vouchers
      .where((v) =>
          v.issuedAt.day == DateTime.now().day &&
          v.issuedAt.month == DateTime.now().month &&
          v.issuedAt.year == DateTime.now().year)
      .fold(0.0, (acc, v) => acc + v.total);

  int get pendingPaymentsCount =>
      _vouchers.where((v) => v.status == VoucherStatus.pending || v.status == VoucherStatus.emitted).length;

  Future<void> loadBillingData(String branchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        manageVouchers.getVouchers(
          branchId: branchId,
          voucherType: _selectedTypeFilter,
          status: _selectedStatusFilter,
        ),
        manageQuotes.getQuotes(branchId: branchId),
      ]);
      _vouchers = results[0] as List<ElectronicVoucher>;
      _quotes = results[1] as List<Quote>;
    } catch (e) {
      _errorMessage = 'Error al cargar facturación y cotizaciones: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByType(VoucherType? type, String branchId) async {
    _selectedTypeFilter = type;
    await loadBillingData(branchId);
  }

  Future<void> filterByStatus(VoucherStatus? status, String branchId) async {
    _selectedStatusFilter = status;
    await loadBillingData(branchId);
  }

  Future<void> loadVoucherDetail(String voucherId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedVoucher = await manageVouchers.getVoucherById(voucherId);
    } catch (e) {
      _errorMessage = 'Error al cargar comprobante: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ElectronicVoucher?> emitVoucher({
    required String branchId,
    required String workOrderId,
    required VoucherType voucherType,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    String? customerAddress,
    required PaymentMethod paymentMethod,
    required List<VoucherItem> items,
    String? quoteId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String effectiveQuoteId = (quoteId != null && quoteId.isNotEmpty) ? quoteId : '';
      if (effectiveQuoteId.isEmpty && workOrderId.isNotEmpty) {
        final existing = _quotes
            .where((q) => q.workOrderId == workOrderId && q.status == QuoteStatus.approved)
            .firstOrNull;
        if (existing != null) {
          effectiveQuoteId = existing.id;
        }
      }
      if (effectiveQuoteId.isEmpty && quoteId != null) {
        effectiveQuoteId = quoteId;
      }
      final emitted = await manageVouchers.emitVoucher(
        quoteId: effectiveQuoteId,
        branchId: branchId,
        workOrderId: workOrderId,
        voucherType: voucherType,
        customerDocumentType: customerDocumentType,
        customerDocumentNumber: customerDocumentNumber,
        customerName: customerName,
        customerAddress: customerAddress,
        paymentMethod: paymentMethod,
        items: items,
      );
      _selectedVoucher = emitted;
      await loadBillingData(branchId);
      return emitted;
    } catch (e) {
      _errorMessage = 'Error al emitir comprobante SUNAT: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processPayment({
    required String voucherId,
    required PaymentMethod paymentMethod,
    required String branchId,
    double? amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final voucher = _selectedVoucher ?? await manageVouchers.getVoucherById(voucherId);
      final paymentAmount =
          amount ?? (voucher.balance > 0 ? voucher.balance : voucher.totalAmount);
      final updated = await manageVouchers.registerPayment(
        voucherId: voucherId,
        amount: paymentAmount,
        method: paymentMethod,
      );
      _selectedVoucher = updated;
      await loadBillingData(branchId);
      return true;
    } catch (e) {
      _errorMessage = 'Error al procesar cobro: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Quote?> createQuote({
    required String branchId,
    String? workOrderId,
    required String customerName,
    required String customerPhone,
    required String vehiclePlate,
    required String vehicleModel,
    required List<dynamic> items,
    required DateTime validUntil,
    double discountPercentage = 0.0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await manageQuotes.createQuote(
        branchId: branchId,
        workOrderId: workOrderId,
        customerName: customerName,
        customerPhone: customerPhone,
        vehiclePlate: vehiclePlate,
        vehicleModel: vehicleModel,
        items: items,
        validUntil: validUntil,
        discountPercentage: discountPercentage,
      );
      _selectedQuote = created;
      await loadBillingData(branchId);
      return created;
    } catch (e) {
      _errorMessage = 'Error al registrar cotización: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Quote?> approveQuote({
    required String quoteId,
    required String branchId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final approved = await manageQuotes.approveQuote(quoteId);
      _selectedQuote = approved;
      await loadBillingData(branchId);
      return approved;
    } catch (e) {
      _errorMessage = 'Error al aprobar cotización: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Quote?> cancelQuote({
    required String quoteId,
    required String branchId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final canceled = await manageQuotes.cancelQuote(quoteId);
      _selectedQuote = canceled;
      await loadBillingData(branchId);
      return canceled;
    } catch (e) {
      _errorMessage = 'Error al cancelar cotización: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ElectronicVoucher?> checkoutDirect({
    required String quoteId,
    required VoucherType type,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    required PaymentMethod method,
    required String branchId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final voucher = await manageCheckouts.checkoutDirect(
        quoteId: quoteId,
        type: type,
        customerDocumentType: customerDocumentType,
        customerDocumentNumber: customerDocumentNumber,
        customerName: customerName,
        method: method,
        branchId: branchId,
      );
      _selectedVoucher = voucher;
      await loadBillingData(branchId);
      return voucher;
    } catch (e) {
      _errorMessage = 'Error en checkout directo: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
