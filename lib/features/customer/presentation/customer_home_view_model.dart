import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_customer_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_checkouts.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_quotes.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_user_profile_context.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/usecases/get_customer_vehicles.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/usecases/get_dtc_alerts.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/usecases/manage_work_orders.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// ViewModel managing the customer portal: executive summary (`GET /api/v1/analytics/me/customer-summary`),
/// customer vehicles & OBD-II/DTC alerts, read-only work orders (`GET /api/v1/work-orders/me`),
/// quote approval/rejection, and virtual payment sessions (`POST /api/v1/payments/sessions`).
class CustomerHomeViewModel extends ChangeNotifier {
  final ManageWorkOrders manageWorkOrders;
  final ManageQuotes? manageQuotes;
  final ManageCheckouts? manageCheckouts;
  final GetCustomerSummaryUseCase? getCustomerSummary;
  final GetCustomerVehicles? getCustomerVehicles;
  final GetUserProfileContextUseCase? getUserProfileContext;
  final GetDtcAlerts? getDtcAlerts;

  CustomerHomeViewModel({
    required this.manageWorkOrders,
    this.manageQuotes,
    this.manageCheckouts,
    this.getCustomerSummary,
    this.getCustomerVehicles,
    this.getUserProfileContext,
    this.getDtcAlerts,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _approvingQuoteId;
  String? get approvingQuoteId => _approvingQuoteId;

  String? _rejectingQuoteId;
  String? get rejectingQuoteId => _rejectingQuoteId;

  String? _payingQuoteId;
  String? get payingQuoteId => _payingQuoteId;

  String? _error;
  String? get error => _error;

  CustomerAnalyticsSummary? _summary;
  CustomerAnalyticsSummary? get summary => _summary;

  List<Vehicle> _vehicles = const [];
  List<Vehicle> get vehicles => _vehicles;

  Map<String, List<DtcAlert>> _vehicleDtcAlerts = const {};
  Map<String, List<DtcAlert>> get vehicleDtcAlerts => _vehicleDtcAlerts;

  List<WorkOrder> _workOrders = const [];
  List<WorkOrder> get workOrders => _workOrders;

  List<Quote> _quotes = const [];
  List<Quote> get quotes => _quotes;

  List<DtcAlert> dtcAlertsForVehicle(String vehicleId) =>
      _vehicleDtcAlerts[vehicleId] ?? const [];

  int get totalDtcAlertsCount {
    final fromSummary = _summary?.activeDtcAlertsCount ?? 0;
    if (fromSummary > 0) return fromSummary;
    return _vehicleDtcAlerts.values
        .expand((alerts) => alerts)
        .where((a) => a.status != DtcStatus.resolved)
        .length;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ordersFuture = manageWorkOrders.getMyWorkOrders();
      final quotesFuture = manageQuotes != null
          ? manageQuotes!.getMyQuotes().catchError((_) => <Quote>[])
          : Future.value(<Quote>[]);
      final summaryFuture = getCustomerSummary != null
          ? getCustomerSummary!
              .execute()
              .then<CustomerAnalyticsSummary?>((s) => s)
              .catchError((_) => null)
          : Future.value(null);

      final results =
          await Future.wait([ordersFuture, quotesFuture, summaryFuture]);
      _workOrders = results[0] as List<WorkOrder>;
      _quotes = results[1] as List<Quote>;
      _summary = results[2] as CustomerAnalyticsSummary?;

      await _loadVehiclesAndDtc();
    } catch (e) {
      _error = 'Error loading your work orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadVehiclesAndDtc() async {
    if (getCustomerVehicles == null) return;

    var customerId = _summary?.customerId ?? '';
    if (customerId.isEmpty && getUserProfileContext != null) {
      try {
        final ctx = await getUserProfileContext!.execute();
        customerId = ctx.customer?.customerId ?? '';
      } catch (_) {}
    }
    if (customerId.isEmpty) return;

    try {
      _vehicles = await getCustomerVehicles!.execute(customerId);
      if (getDtcAlerts != null && _vehicles.isNotEmpty) {
        final entries = await Future.wait(
          _vehicles.map((v) async {
            try {
              final alerts = await getDtcAlerts!.getForVehicle(vehicleId: v.id);
              return MapEntry(v.id, alerts);
            } catch (_) {
              return MapEntry(v.id, const <DtcAlert>[]);
            }
          }),
        );
        _vehicleDtcAlerts = Map.fromEntries(entries);
      }
    } catch (_) {
      // Keep existing vehicles silently if customer profile/vehicles call fails.
    }
  }

  /// Approves a `DRAFT` quote belonging to the customer (`POST /api/v1/quotes/{id}/approvals`).
  Future<bool> approveQuote(Quote quote) async {
    final quotesUseCase = manageQuotes;
    if (quotesUseCase == null) {
      _error = 'Quotes service is not available.';
      notifyListeners();
      return false;
    }

    _approvingQuoteId = quote.id;
    _error = null;
    notifyListeners();

    try {
      final updated = await quotesUseCase.approveQuote(
        quote.id,
        currentQuote: quote,
      );
      _quotes = _quotes
          .map((q) => q.id == updated.id ? updated : q)
          .toList();
      return true;
    } catch (e) {
      _error = 'No se pudo aprobar la cotización: $e';
      return false;
    } finally {
      _approvingQuoteId = null;
      notifyListeners();
    }
  }

  /// Rejects/cancels a `DRAFT` quote belonging to the customer (`POST /api/v1/quotes/{id}/cancellations`).
  Future<bool> rejectQuote(Quote quote) async {
    final quotesUseCase = manageQuotes;
    if (quotesUseCase == null) {
      _error = 'Quotes service is not available.';
      notifyListeners();
      return false;
    }

    _rejectingQuoteId = quote.id;
    _error = null;
    notifyListeners();

    try {
      final updated = await quotesUseCase.cancelQuote(
        quote.id,
        currentQuote: quote,
      );
      _quotes = _quotes
          .map((q) => q.id == updated.id ? updated : q)
          .toList();
      return true;
    } catch (e) {
      _error = 'No se pudo rechazar la cotización: $e';
      return false;
    } finally {
      _rejectingQuoteId = null;
      notifyListeners();
    }
  }

  /// Returns whether the work order associated with [quote] is already `PAID`.
  bool isQuotePaid(Quote quote) {
    final woId = quote.workOrderId;
    if (woId == null || woId.isEmpty) return false;
    final matchingOrder = _workOrders.where((o) => o.id == woId).firstOrNull;
    return matchingOrder?.isPaid ?? false;
  }

  /// Returns whether [quote] can be paid online by the customer
  /// (approved quote whose associated work order is `COMPLETED` and not yet `PAID`).
  bool canPayQuote(Quote quote) {
    if (quote.status != QuoteStatus.approved) return false;
    if (isQuotePaid(quote)) return false;
    final woId = quote.workOrderId;
    if (woId == null || woId.isEmpty) return true;
    final matchingOrder = _workOrders.where((o) => o.id == woId).firstOrNull;
    if (matchingOrder == null) return true;
    return matchingOrder.status == WorkOrderStatus.completed;
  }

  /// Creates a virtual payment session (`POST /api/v1/payments/sessions`) for an approved [quote].
  Future<MercadoPagoPreference?> createMercadoPagoPreference(Quote quote) async {
    final checkouts = manageCheckouts;
    if (checkouts == null) {
      _error = 'Mercado Pago checkout is not available.';
      notifyListeners();
      return null;
    }

    _payingQuoteId = quote.id;
    _error = null;
    notifyListeners();

    try {
      return await checkouts.createPaymentSession(
        quoteId: quote.id,
        provider: 'MERCADO_PAGO',
      );
    } catch (e) {
      _error = 'No se pudo iniciar el pago con Mercado Pago: $e';
      return null;
    } finally {
      _payingQuoteId = null;
      notifyListeners();
    }
  }
}
