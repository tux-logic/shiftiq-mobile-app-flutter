import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case managing weekly operating hours and date exceptions for
/// workshops and physical branches.
class ManageOperatingHoursUseCase {
  final CoreRepository repository;

  const ManageOperatingHoursUseCase({required this.repository});

  /// Fetches both weekly operating hours and date exceptions for [branchId]
  /// in parallel for customer availability resolution.
  Future<BranchOperatingSchedule> getBranchSchedule(String branchId) async {
    final results = await Future.wait([
      repository.getBranchOperatingHours(branchId),
      repository.getBranchOperatingHoursExceptions(branchId),
    ]);
    return BranchOperatingSchedule(
      weeklyDays: results[0] as List<OperatingHoursDay>,
      exceptions: results[1] as List<OperatingHoursException>,
    );
  }

  Future<List<OperatingHoursDay>> getBranchOperatingHours(String branchId) =>
      repository.getBranchOperatingHours(branchId);

  Future<List<OperatingHoursDay>> updateBranchOperatingHours(
    String branchId,
    List<OperatingHoursDay> days,
  ) =>
      repository.updateBranchOperatingHours(branchId, days);

  Future<void> deleteBranchOperatingHours(String branchId) =>
      repository.deleteBranchOperatingHours(branchId);

  Future<List<OperatingHoursException>> getBranchExceptions(String branchId) =>
      repository.getBranchOperatingHoursExceptions(branchId);

  Future<OperatingHoursException> createBranchException({
    required String branchId,
    required String date,
    required bool open,
    String? openTime,
    String? closeTime,
    String? reason,
  }) =>
      repository.createBranchOperatingHoursException(
        branchId: branchId,
        date: date,
        open: open,
        openTime: openTime,
        closeTime: closeTime,
        reason: reason,
      );

  Future<void> deleteBranchException(String branchId, String exceptionId) =>
      repository.deleteBranchOperatingHoursException(branchId, exceptionId);

  Future<List<OperatingHoursDay>> getWorkshopOperatingHours(
    String workshopId,
  ) =>
      repository.getWorkshopOperatingHours(workshopId);

  Future<List<OperatingHoursDay>> updateWorkshopOperatingHours(
    String workshopId,
    List<OperatingHoursDay> days,
  ) =>
      repository.updateWorkshopOperatingHours(workshopId, days);

  Future<List<OperatingHoursException>> getWorkshopExceptions(
    String workshopId,
  ) =>
      repository.getWorkshopOperatingHoursExceptions(workshopId);

  Future<OperatingHoursException> createWorkshopException({
    required String workshopId,
    required String date,
    required bool open,
    String? openTime,
    String? closeTime,
    String? reason,
  }) =>
      repository.createWorkshopOperatingHoursException(
        workshopId: workshopId,
        date: date,
        open: open,
        openTime: openTime,
        closeTime: closeTime,
        reason: reason,
      );

  Future<void> deleteWorkshopException(String workshopId, String exceptionId) =>
      repository.deleteWorkshopOperatingHoursException(workshopId, exceptionId);
}
