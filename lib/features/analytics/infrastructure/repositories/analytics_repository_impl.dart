import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/dtos/analytics_dto.dart';

/// Implementation of [AnalyticsRepository] orchestrating remote API calls and domain entity mapping.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsApi analyticsApi;

  const AnalyticsRepositoryImpl({required this.analyticsApi});

  @override
  Future<BranchAnalyticsSummary> getBranchSummary(String branchId) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('Branch ID cannot be empty');
    }
    final json = await analyticsApi.getBranchSummary(branchId);
    return AnalyticsDto.branchSummaryFromJson(json);
  }

  @override
  Future<List<FinancialAnalyticsSnapshot>> getBranchFinancialAnalytics({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('Branch ID cannot be empty');
    }

    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw ArgumentError('startDate cannot be after endDate');
      }
      final differenceInDays = endDate.difference(startDate).inDays;
      if (differenceInDays > 365) {
        throw ArgumentError('Date range cannot exceed 365 days');
      }
    }

    String? formatDate(DateTime? date) {
      if (date == null) return null;
      final y = date.year.toString().padLeft(4, '0');
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }

    final rawList = await analyticsApi.getBranchFinancialAnalytics(
      branchId: branchId,
      startDate: formatDate(startDate),
      endDate: formatDate(endDate),
    );

    return AnalyticsDto.financialSnapshotListFromJson(rawList);
  }

  @override
  Future<NetworkAnalyticsSummary> getNetworkSummary() async {
    final json = await analyticsApi.getNetworkSummary();
    return AnalyticsDto.networkSummaryFromJson(json);
  }
}
