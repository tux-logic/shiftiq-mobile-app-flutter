import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/usecases/manage_work_orders.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// ViewModel managing the customer portal home screen, including read-only
/// work orders retrieved via `GET /api/v1/work-orders/me`.
class CustomerHomeViewModel extends ChangeNotifier {
  final ManageWorkOrders manageWorkOrders;

  CustomerHomeViewModel({
    required this.manageWorkOrders,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<WorkOrder> _workOrders = const [];
  List<WorkOrder> get workOrders => _workOrders;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workOrders = await manageWorkOrders.getMyWorkOrders();
    } catch (e) {
      _error = 'Error loading your work orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
