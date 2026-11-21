import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_branch_financial_analytics.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_branch_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_network_analytics_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/controllers/dashboard_view_model.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  bool shouldThrow = false;
  BranchAnalyticsSummary? stubSummary;
  List<FinancialAnalyticsSnapshot>? stubFinancialSnapshots;
  NetworkAnalyticsSummary? stubNetworkSummary;

  @override
  Future<BranchAnalyticsSummary> getBranchSummary(String branchId) async {
    if (shouldThrow) {
      throw Exception('Server error loading analytics');
    }
    return stubSummary ??
        BranchAnalyticsSummary(
          branchId: branchId,
          totalRevenue: 24850.00,
          completedWorkOrdersCount: 12,
          totalAppointmentsCount: 8,
          lowStockAlertsCount: 3,
          dtcAlertsCount: 2,
        );
  }

  @override
  Future<List<FinancialAnalyticsSnapshot>> getBranchFinancialAnalytics({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldThrow) {
      throw Exception('Server error loading financial snapshots');
    }

    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw ArgumentError('startDate cannot be after endDate');
      }
      if (endDate.difference(startDate).inDays > 365) {
        throw ArgumentError('Date range cannot exceed 365 days');
      }
    }

    return stubFinancialSnapshots ??
        [
          FinancialAnalyticsSnapshot(
            id: 'snap-01',
            branchId: branchId,
            snapshotDate: DateTime(2026, 10, 6),
            totalRevenue: 950.00,
            completedWorkOrdersCount: 3,
            totalAppointmentsCount: 5,
            lowStockAlertsCount: 2,
            dtcAlertsCount: 0,
          ),
          FinancialAnalyticsSnapshot(
            id: 'snap-02',
            branchId: branchId,
            snapshotDate: DateTime(2026, 10, 7),
            totalRevenue: 1250.00,
            completedWorkOrdersCount: 4,
            totalAppointmentsCount: 7,
            lowStockAlertsCount: 2,
            dtcAlertsCount: 1,
          ),
        ];
  }

  @override
  Future<NetworkAnalyticsSummary> getNetworkSummary() async {
    if (shouldThrow) {
      throw Exception('Forbidden access to network analytics');
    }
    return stubNetworkSummary ??
        const NetworkAnalyticsSummary(
          totalActiveBranchesCount: 3,
          totalNetworkRevenue: 4850.00,
          totalNetworkCompletedWorkOrders: 14,
          totalNetworkAppointments: 22,
          totalNetworkDtcAlerts: 3,
        );
  }
}

class MockSessionStorage extends SessionStorage {
  MockSessionStorage() : super(appDatabase: null);

  @override
  Future<String?> getActiveBranchId() async => 'b-01-smp';

  @override
  Future<String?> getActiveBranchName() async =>
      'Sede Central - San Martín de Porres';
}

void main() {
  late MockAnalyticsRepository mockRepository;
  late GetBranchSummaryUseCase getBranchSummaryUseCase;
  late GetBranchFinancialAnalyticsUseCase getBranchFinancialAnalyticsUseCase;
  late GetNetworkAnalyticsSummaryUseCase getNetworkAnalyticsSummaryUseCase;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    getBranchSummaryUseCase =
        GetBranchSummaryUseCase(repository: mockRepository);
    getBranchFinancialAnalyticsUseCase =
        GetBranchFinancialAnalyticsUseCase(repository: mockRepository);
    getNetworkAnalyticsSummaryUseCase =
        GetNetworkAnalyticsSummaryUseCase(repository: mockRepository);
  });

  group('GetBranchSummaryUseCase', () {
    test('should return BranchAnalyticsSummary when repository succeeds',
        () async {
      final summary = await getBranchSummaryUseCase.execute('b-01-smp');

      expect(summary.branchId, equals('b-01-smp'));
      expect(summary.totalRevenue, equals(24850.00));
      expect(summary.completedWorkOrdersCount, equals(12));
      expect(summary.totalAppointmentsCount, equals(8));
      expect(summary.lowStockAlertsCount, equals(3));
      expect(summary.dtcAlertsCount, equals(2));
      expect(summary.hasCriticalAlerts, isTrue);
      expect(summary.totalAlertsCount, equals(5));
      expect(summary.formattedRevenue, equals('S/ 24850.00'));
    });

    test('should propagate exception when repository throws', () async {
      mockRepository.shouldThrow = true;

      expect(
        () => getBranchSummaryUseCase.execute('b-01-smp'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('GetBranchFinancialAnalyticsUseCase', () {
    test('should retrieve historical snapshots within valid range', () async {
      final snapshots = await getBranchFinancialAnalyticsUseCase.execute(
        branchId: 'b-01-smp',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 10),
      );

      expect(snapshots.length, equals(2));
      expect(snapshots.first.id, equals('snap-01'));
      expect(snapshots.first.formattedRevenue, equals('S/ 950.00'));
      expect(snapshots.first.formattedDate, equals('2026-10-06'));
      expect(snapshots[1].dtcAlertsCount, equals(1));
    });

    test('should throw ArgumentError when startDate is after endDate', () async {
      expect(
        () => getBranchFinancialAnalyticsUseCase.execute(
          branchId: 'b-01-smp',
          startDate: DateTime(2026, 10, 20),
          endDate: DateTime(2026, 10, 10),
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError when date range exceeds 365 days',
        () async {
      expect(
        () => getBranchFinancialAnalyticsUseCase.execute(
          branchId: 'b-01-smp',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('GetNetworkAnalyticsSummaryUseCase', () {
    test('should return aggregated platform metrics for authorized callers',
        () async {
      final network = await getNetworkAnalyticsSummaryUseCase.execute();

      expect(network.totalActiveBranchesCount, equals(3));
      expect(network.totalNetworkRevenue, equals(4850.00));
      expect(network.totalNetworkCompletedWorkOrders, equals(14));
      expect(network.totalNetworkAppointments, equals(22));
      expect(network.totalNetworkDtcAlerts, equals(3));
      expect(network.formattedNetworkRevenue, equals('S/ 4850.00'));
    });

    test('should propagate exception when forbidden', () async {
      mockRepository.shouldThrow = true;

      expect(
        () => getNetworkAnalyticsSummaryUseCase.execute(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DashboardViewModel', () {
    late MockSessionStorage mockStorage;
    late DashboardViewModel viewModel;

    setUp(() {
      mockStorage = MockSessionStorage();
      viewModel = DashboardViewModel(
        getBranchSummaryUseCase: getBranchSummaryUseCase,
        sessionStorage: mockStorage,
      );
    });

    test('init() should load active branch info and fetch summary', () async {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.summary, isNull);

      await viewModel.init();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.activeBranchId, equals('b-01-smp'));
      expect(viewModel.activeBranchName,
          equals('Sede Central - San Martín de Porres'));
      expect(viewModel.summary, isNotNull);
      expect(viewModel.summary!.completedWorkOrdersCount, equals(12));
      expect(viewModel.error, isNull);
    });

    test('loadSummary() should set error when use case throws', () async {
      mockRepository.shouldThrow = true;

      await viewModel.loadSummary();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.summary, isNull);
      expect(viewModel.error, contains('No se pudo cargar el resumen de KPIs'));
    });
  });
}
