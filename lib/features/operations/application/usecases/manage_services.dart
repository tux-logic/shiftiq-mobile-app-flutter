import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Application use case to manage workshop labor services catalog.
class ManageServices {
  final OperationsRepository repository;

  const ManageServices({required this.repository});

  /// Creates a new labor service within a workshop branch catalog.
  Future<WorkshopService> createService({
    required String branchId,
    required String name,
    required double price,
  }) async {
    final trimmedBranchId = branchId.trim();
    final trimmedName = name.trim();

    if (trimmedBranchId.isEmpty) {
      throw ArgumentError('Branch ID cannot be empty.');
    }
    if (trimmedName.isEmpty) {
      throw ArgumentError('Service name cannot be empty.');
    }
    if (price <= 0) {
      throw ArgumentError('Service price must be greater than zero.');
    }

    return repository.createService(
      branchId: trimmedBranchId,
      name: trimmedName,
      price: price,
    );
  }

  /// Retrieves all labor services offered by a branch.
  Future<List<WorkshopService>> getBranchServices(String branchId) async {
    final trimmedBranchId = branchId.trim();
    if (trimmedBranchId.isEmpty) {
      throw ArgumentError('Branch ID cannot be empty.');
    }

    return repository.getBranchServices(trimmedBranchId);
  }

  /// Updates an existing labor service name or unit price.
  Future<WorkshopService> updateService({
    required String serviceId,
    required String name,
    required double price,
  }) async {
    final trimmedServiceId = serviceId.trim();
    final trimmedName = name.trim();

    if (trimmedServiceId.isEmpty) {
      throw ArgumentError('Service ID cannot be empty.');
    }
    if (trimmedName.isEmpty) {
      throw ArgumentError('Service name cannot be empty.');
    }
    if (price <= 0) {
      throw ArgumentError('Service price must be greater than zero.');
    }

    return repository.updateService(
      serviceId: trimmedServiceId,
      name: trimmedName,
      price: price,
    );
  }

  /// Deletes a service from the branch catalog if not used in active repair tasks.
  Future<void> deleteService(String serviceId) async {
    final trimmedServiceId = serviceId.trim();
    if (trimmedServiceId.isEmpty) {
      throw ArgumentError('Service ID cannot be empty.');
    }

    return repository.deleteService(trimmedServiceId);
  }
}
