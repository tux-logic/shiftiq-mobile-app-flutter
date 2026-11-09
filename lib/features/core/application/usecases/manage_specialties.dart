import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case managing technical specialties catalog in a workshop.
class ManageSpecialtiesUseCase {
  final CoreRepository repository;

  ManageSpecialtiesUseCase({required this.repository});

  Future<WorkshopSpecialty> create({
    required String workshopId,
    required String name,
    required String code,
    String? description,
  }) {
    return repository.createSpecialty(
      workshopId: workshopId,
      name: name,
      code: code,
      description: description,
    );
  }

  Future<List<WorkshopSpecialty>> list({
    required String workshopId,
    bool activeOnly = true,
  }) {
    return repository.getSpecialties(
      workshopId: workshopId,
      activeOnly: activeOnly,
    );
  }

  Future<WorkshopSpecialty> getById({
    required String workshopId,
    required String specialtyId,
  }) {
    return repository.getSpecialtyById(
      workshopId: workshopId,
      specialtyId: specialtyId,
    );
  }

  Future<WorkshopSpecialty> update({
    required String workshopId,
    required String specialtyId,
    required String name,
    String? description,
  }) {
    return repository.updateSpecialty(
      workshopId: workshopId,
      specialtyId: specialtyId,
      name: name,
      description: description,
    );
  }

  Future<void> deactivate({
    required String workshopId,
    required String specialtyId,
  }) {
    return repository.deactivateSpecialty(
      workshopId: workshopId,
      specialtyId: specialtyId,
    );
  }

  Future<List<SpecialtyRevisionHistory>> history({
    required String workshopId,
    required String specialtyId,
  }) {
    return repository.getSpecialtyHistory(
      workshopId: workshopId,
      specialtyId: specialtyId,
    );
  }
}
