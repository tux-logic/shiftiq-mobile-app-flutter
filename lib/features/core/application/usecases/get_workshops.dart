import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case retrieving workshops associated with an owner or caller.
class GetWorkshopsUseCase {
  final CoreRepository repository;

  GetWorkshopsUseCase({required this.repository});

  Future<List<Workshop>> execute({String? ownerId}) {
    return repository.getWorkshops(ownerId: ownerId);
  }

  Future<Workshop> getById(String workshopId) {
    return repository.getWorkshopById(workshopId);
  }
}
