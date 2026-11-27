import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_customer_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_checkouts.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_quotes.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_customer_branch_catalog.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_user_profile_context.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/create_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/usecases/get_customer_vehicles.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/usecases/get_dtc_alerts.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/usecases/register_vehicle.dart';
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
  final RegisterVehicle? registerVehicle;
  final GetUserProfileContextUseCase? getUserProfileContext;
  final GetDtcAlerts? getDtcAlerts;
  final GetCustomerBranchCatalogUseCase? getBranchCatalog;
  final CreateAppointmentUseCase? createAppointment;

  CustomerHomeViewModel({
    required this.manageWorkOrders,
    this.manageQuotes,
    this.manageCheckouts,
    this.getCustomerSummary,
    this.getCustomerVehicles,
    this.registerVehicle,
    this.getUserProfileContext,
    this.getDtcAlerts,
    this.getBranchCatalog,
    this.createAppointment,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _approvingQuoteId;
  String? get approvingQuoteId => _approvingQuoteId;

  String? _rejectingQuoteId;
  String? get rejectingQuoteId => _rejectingQuoteId;

  String? _payingQuoteId;
  String? get payingQuoteId => _payingQuoteId;

  bool _isRegisteringVehicle = false;
  bool get isRegisteringVehicle => _isRegisteringVehicle;

  bool _isSchedulingAppointment = false;
  bool get isSchedulingAppointment => _isSchedulingAppointment;

  String? _error;
  String? get error => _error;

  CustomerAnalyticsSummary? _summary;
  CustomerAnalyticsSummary? get summary => _summary;

  List<CustomerBranchCatalogItem> _branches = const [];
  List<CustomerBranchCatalogItem> get branches => _branches;

  String _customerId = '';

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

  /// Registers a new vehicle for the authenticated customer via `POST /api/v1/vehicles`.
  Future<Vehicle?> addVehicle({
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
  }) async {
    if (registerVehicle == null) {
      _error = 'Vehicle registration is unavailable in this session.';
      notifyListeners();
      return null;
    }

    _isRegisteringVehicle = true;
    _error = null;
    notifyListeners();

    try {
      final created = await registerVehicle!.execute(
        plateNumber: plateNumber,
        brand: brand,
        model: model,
        year: year,
        vin: vin,
      );
      _vehicles = [..._vehicles, created];
      return created;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isRegisteringVehicle = false;
      notifyListeners();
    }
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
      final branchesFuture = getBranchCatalog != null
          ? getBranchCatalog!
              .execute()
              .catchError((_) => <CustomerBranchCatalogItem>[])
          : Future.value(<CustomerBranchCatalogItem>[]);

      final results = await Future.wait([
        ordersFuture,
        quotesFuture,
        summaryFuture,
        branchesFuture,
      ]);
      _workOrders = results[0] as List<WorkOrder>;
      _quotes = results[1] as List<Quote>;
      _summary = results[2] as CustomerAnalyticsSummary?;
      _branches = results[3] as List<CustomerBranchCatalogItem>;
      if ((_summary?.customerId ?? '').isNotEmpty) {
        _customerId = _summary!.customerId;
      }

      await _loadVehiclesAndDtc();
    } catch (e) {
      _error = 'Error loading your work orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _resolveCustomerId() async {
    if ((_summary?.customerId ?? '').isNotEmpty) {
      _customerId = _summary!.customerId;
      return _customerId;
    }
    if (_customerId.isNotEmpty) return _customerId;
    if (getUserProfileContext != null) {
      try {
        final ctx = await getUserProfileContext!.execute();
        _customerId = ctx.customer?.customerId ?? '';
      } catch (_) {}
    }
    return _customerId;
  }

  /// Schedules a new workshop appointment for the authenticated customer via
  /// `POST /api/v1/appointments` and refreshes the customer summary.
  Future<Appointment?> scheduleAppointment({
    required String branchId,
    required String vehicleId,
    required DateTime scheduledStart,
    DateTime? scheduledEnd,
    String? notes,
  }) async {
    if (createAppointment == null) {
      _error = 'Appointment scheduling is unavailable in this session.';
      notifyListeners();
      return null;
    }

    _isSchedulingAppointment = true;
    _error = null;
    notifyListeners();

    try {
      final customerId = await _resolveCustomerId();
      if (customerId.isEmpty) {
        _error = 'Unable to resolve customer profile for appointment booking.';
        return null;
      }

      final vehicle = _vehicles.where((v) => v.id == vehicleId).firstOrNull;
      final created = await createAppointment!.execute(
        branchId: branchId,
        customerId: customerId,
        vehicleId: vehicleId,
        scheduledStart: scheduledStart,
        scheduledEnd: scheduledEnd,
        notes: notes?.trim() ?? '',
        vehiclePlate: vehicle?.plateNumber ?? 'S/P',
        vehicleModel: vehicle != null
            ? '${vehicle.brand} ${vehicle.model}'.trim()
            : 'Vehicle',
      );

      if (getCustomerSummary != null) {
        try {
          _summary = await getCustomerSummary!.execute();
        } catch (_) {}
      }
      return created;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isSchedulingAppointment = false;
      notifyListeners();
    }
  }

  Future<void> _loadVehiclesAndDtc() async {
    if (getCustomerVehicles == null) return;

    final customerId = await _resolveCustomerId();
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
