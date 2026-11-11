import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_branch_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Presentation controller managing dashboard state, daily branch KPIs, and active work orders.
class DashboardViewModel extends ChangeNotifier {
  final GetBranchSummaryUseCase getBranchSummaryUseCase;
  final ManageWorkOrders? manageWorkOrders;
  final SessionStorage sessionStorage;

  DashboardViewModel({
    required this.getBranchSummaryUseCase,
    this.manageWorkOrders,
    required this.sessionStorage,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  BranchAnalyticsSummary? _summary;
  BranchAnalyticsSummary? get summary => _summary;

  List<WorkOrder> _recentWorkOrders = [];
  List<WorkOrder> get recentWorkOrders => _recentWorkOrders;

  String _activeBranchId = '';
  String get activeBranchId => _activeBranchId;

  String _activeBranchName = ApiConstants.defaultBranchName;
  String get activeBranchName => _activeBranchName;

  Future<void> init() async {
    _activeBranchId = await sessionStorage.getActiveBranchId() ?? ApiConstants.defaultBranchId;
    _activeBranchName =
        await sessionStorage.getActiveBranchName() ??
        ApiConstants.defaultBranchName;
    notifyListeners();
    await loadSummary();
  }

  Future<void> loadSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await getBranchSummaryUseCase.execute(_activeBranchId);
      if (manageWorkOrders != null) {
        final orders = await manageWorkOrders!.getWorkOrders(
          branchId: _activeBranchId,
        );
        _recentWorkOrders = orders.take(4).toList();
      }
    } catch (e) {
      _error = 'No se pudo cargar el resumen de KPIs: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadSummary();
}
