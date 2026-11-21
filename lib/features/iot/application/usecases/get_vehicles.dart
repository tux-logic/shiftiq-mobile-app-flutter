import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to retrieve vehicles available for linking or inspect specific vehicles.
class GetVehicles {
  final IotRepository repository;

  const GetVehicles({required this.repository});

  /// Retrieves vehicles belonging to a branch that are available for OBD2 scanner pairing.
  Future<List<Vehicle>> execute({
    required String branchId,
    String status = 'available-for-linking',
  }) async {
    final trimmedBranchId = branchId.trim();
    if (trimmedBranchId.isEmpty) {
      throw ArgumentError('Branch ID cannot be empty.');
    }

    return repository.getBranchVehiclesAvailableForLinking(trimmedBranchId);
  }

  /// Retrieves a specific vehicle by its unique identifier.
  Future<Vehicle> getById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Vehicle ID cannot be empty.');
    }

    return repository.getVehicleById(trimmedId);
  }
}
