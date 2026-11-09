import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_branch_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';

/// Presentation controller managing dashboard state and daily branch KPIs.
class DashboardViewModel extends ChangeNotifier {
  final GetBranchSummaryUseCase getBranchSummaryUseCase;
  final SessionStorage sessionStorage;

  DashboardViewModel({
    required this.getBranchSummaryUseCase,
    required this.sessionStorage,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  BranchAnalyticsSummary? _summary;
  BranchAnalyticsSummary? get summary => _summary;

  String _activeBranchId = '';
  String get activeBranchId => _activeBranchId;

  String _activeBranchName = 'Sede Principal';
  String get activeBranchName => _activeBranchName;

  Future<void> init() async {
    _activeBranchId = await sessionStorage.getActiveBranchId() ?? 'b-01-smp';
    _activeBranchName =
        await sessionStorage.getActiveBranchName() ??
        'Sede Central - San Martín de Porres';
    notifyListeners();
    await loadSummary();
  }

  Future<void> loadSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await getBranchSummaryUseCase.execute(_activeBranchId);
    } catch (e) {
      _error = 'No se pudo cargar el resumen de KPIs: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadSummary();
}
