import 'package:flutter/foundation.dart';
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
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_type.dart';

class BillingViewModel extends ChangeNotifier {
  final GetVouchersByBranchQueryService getVouchersQuery;
  final GetVoucherDetailQueryService getVoucherDetailQuery;
  final GetQuotesQueryService getQuotesQuery;
  final EmitVoucherCommandService emitVoucherCommand;
  final ProcessPaymentCommandService processPaymentCommand;
  final CreateQuoteCommandService createQuoteCommand;

  BillingViewModel({
    required this.getVouchersQuery,
    required this.getVoucherDetailQuery,
    required this.getQuotesQuery,
    required this.emitVoucherCommand,
    required this.processPaymentCommand,
    required this.createQuoteCommand,
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
      _vouchers.where((v) => v.status == VoucherStatus.issued).length;

  Future<void> loadBillingData(String branchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        getVouchersQuery.execute(
          branchId: branchId,
          voucherType: _selectedTypeFilter,
          status: _selectedStatusFilter,
        ),
        getQuotesQuery.execute(branchId: branchId),
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
      _selectedVoucher = await getVoucherDetailQuery.execute(voucherId);
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final emitted = await emitVoucherCommand.execute(
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await processPaymentCommand.execute(
        voucherId: voucherId,
        paymentMethod: paymentMethod,
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
    required List<VoucherItem> items,
    required DateTime validUntil,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await createQuoteCommand.execute(
        branchId: branchId,
        workOrderId: workOrderId,
        customerName: customerName,
        customerPhone: customerPhone,
        vehiclePlate: vehiclePlate,
        vehicleModel: vehicleModel,
        items: items,
        validUntil: validUntil,
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
}
