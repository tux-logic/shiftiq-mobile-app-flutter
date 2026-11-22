import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/dtos/analytics_dto.dart';

/// ViewModel managing the mechanic's personal operational summary dashboard
/// backed by `GET /api/v1/analytics/me/employee-summary`.
class EmployeeDashboardViewModel extends ChangeNotifier {
  final AnalyticsApi analyticsApi;
  final SessionStorage sessionStorage;

  EmployeeDashboardViewModel({
    required this.analyticsApi,
    required this.sessionStorage,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _activeBranchName = ApiConstants.defaultBranchName;
  String get activeBranchName => _activeBranchName;

  EmployeeAnalyticsSummary? _summary;
  EmployeeAnalyticsSummary? get summary => _summary;

  Future<void> init() async {
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
      final raw = await analyticsApi.getEmployeeSummary();
      _summary = AnalyticsDto.employeeSummaryFromJson(raw);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadSummary();
}
