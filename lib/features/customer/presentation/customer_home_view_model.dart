import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_checkouts.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_quotes.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/usecases/manage_work_orders.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// ViewModel managing the customer portal home screen, including read-only
/// work orders (`GET /api/v1/work-orders/me`), quotes (`GET /api/v1/quotes/me`),
/// and Mercado Pago preference creation (`POST /api/v1/payments/mercadopago/preferences`).
class CustomerHomeViewModel extends ChangeNotifier {
  final ManageWorkOrders manageWorkOrders;
  final ManageQuotes? manageQuotes;
  final ManageCheckouts? manageCheckouts;

  CustomerHomeViewModel({
    required this.manageWorkOrders,
    this.manageQuotes,
    this.manageCheckouts,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _payingQuoteId;
  String? get payingQuoteId => _payingQuoteId;

  String? _error;
  String? get error => _error;

  List<WorkOrder> _workOrders = const [];
  List<WorkOrder> get workOrders => _workOrders;

  List<Quote> _quotes = const [];
  List<Quote> get quotes => _quotes;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ordersFuture = manageWorkOrders.getMyWorkOrders();
      final quotesFuture = manageQuotes != null
          ? manageQuotes!.getMyQuotes().catchError((_) => <Quote>[])
          : Future.value(<Quote>[]);

      final results = await Future.wait([ordersFuture, quotesFuture]);
      _workOrders = results[0] as List<WorkOrder>;
      _quotes = results[1] as List<Quote>;
    } catch (e) {
      _error = 'Error loading your work orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns whether [quote] can be paid online by the customer
  /// (approved quote whose associated work order is completed, or no linked OT filter blocking it).
  bool canPayQuote(Quote quote) {
    if (quote.status != QuoteStatus.approved) return false;
    final woId = quote.workOrderId;
    if (woId == null || woId.isEmpty) return true;
    final matchingOrder = _workOrders.where((o) => o.id == woId).firstOrNull;
    if (matchingOrder == null) return true;
    return matchingOrder.isCompleted;
  }

  /// Creates a Mercado Pago Checkout Pro preference for an approved [quote].
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
      return await checkouts.createMercadoPagoPreference(
        quoteId: quote.id,
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
