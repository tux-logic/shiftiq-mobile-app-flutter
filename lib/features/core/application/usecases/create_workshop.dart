import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case orchestrating the creation of a new automotive workshop.
class CreateWorkshopUseCase {
  final CoreRepository repository;

  CreateWorkshopUseCase({required this.repository});

  Future<Workshop> execute({
    required String ownerId,
    required String businessName,
    required String brandName,
    required String taxId,
    int mileageIntervalConfig = 5000,
  }) {
    return repository.createWorkshop(
      ownerId: ownerId,
      businessName: businessName,
      brandName: brandName,
      taxId: taxId,
      mileageIntervalConfig: mileageIntervalConfig,
    );
  }
}
