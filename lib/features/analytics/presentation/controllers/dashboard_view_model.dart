import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_branch_financial_analytics.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_branch_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_network_analytics_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Presentation controller managing dashboard state, daily branch KPIs, and active work orders.
class DashboardViewModel extends ChangeNotifier {
  final GetBranchSummaryUseCase getBranchSummaryUseCase;
  final GetBranchFinancialAnalyticsUseCase? getBranchFinancialAnalyticsUseCase;
  final GetNetworkAnalyticsSummaryUseCase? getNetworkAnalyticsSummaryUseCase;
  final ManageWorkOrders? manageWorkOrders;
  final SessionStorage sessionStorage;

  DashboardViewModel({
    required this.getBranchSummaryUseCase,
    this.getBranchFinancialAnalyticsUseCase,
    this.getNetworkAnalyticsSummaryUseCase,
    this.manageWorkOrders,
    required this.sessionStorage,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  BranchAnalyticsSummary? _summary;
  BranchAnalyticsSummary? get summary => _summary;

  NetworkAnalyticsSummary? _networkSummary;
  NetworkAnalyticsSummary? get networkSummary => _networkSummary;

  List<FinancialAnalyticsSnapshot> _snapshots = [];
  List<FinancialAnalyticsSnapshot> get snapshots => _snapshots;

  int _selectedRangeDays = 14;
  int get selectedRangeDays => _selectedRangeDays;

  double get totalRangeRevenue =>
      _snapshots.fold(0.0, (sum, item) => sum + item.totalRevenue);

  int get totalRangeWorkOrders => _snapshots.fold(
      0, (sum, item) => sum + item.completedWorkOrdersCount);

  int get totalRangeAppointments =>
      _snapshots.fold(0, (sum, item) => sum + item.totalAppointmentsCount);

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
      await Future.wait([
        _loadFinancialSeries(),
        _loadNetworkSummary(),
      ]);
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

  Future<void> setRangeDays(int days) async {
    if (_selectedRangeDays == days) return;
    _selectedRangeDays = days;
    notifyListeners();
    await _loadFinancialSeries();
    notifyListeners();
  }

  Future<void> _loadFinancialSeries() async {
    if (getBranchFinancialAnalyticsUseCase == null || _activeBranchId.isEmpty) {
      _snapshots = [];
      return;
    }
    try {
      final now = DateTime.now();
      final start = now.subtract(Duration(days: _selectedRangeDays - 1));
      final result = await getBranchFinancialAnalyticsUseCase!.execute(
        branchId: _activeBranchId,
        startDate: start,
        endDate: now,
      );
      result.sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate));
      _snapshots = result;
    } catch (_) {
      // Roles without ANALYTICS_READ or empty history fall back cleanly.
      _snapshots = [];
    }
  }

  Future<void> _loadNetworkSummary() async {
    if (getNetworkAnalyticsSummaryUseCase == null) {
      _networkSummary = null;
      return;
    }
    try {
      _networkSummary = await getNetworkAnalyticsSummaryUseCase!.execute();
    } catch (_) {
      // Non-owner/admin callers receive 403 and hide network rollup cleanly.
      _networkSummary = null;
    }
  }

  Future<void> refresh() => loadSummary();
}
