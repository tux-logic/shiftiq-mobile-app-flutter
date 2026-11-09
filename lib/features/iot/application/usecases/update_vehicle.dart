import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to modify or remove an existing vehicle.
class UpdateVehicle {
  final IotRepository repository;

  const UpdateVehicle({required this.repository});

  /// Updates vehicle metadata after validation.
  Future<Vehicle> execute({
    required String id,
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
    String? photoUrl,
  }) async {
    final trimmedId = id.trim();
    final trimmedPlate = plateNumber.trim().toUpperCase();
    final trimmedBrand = brand.trim();
    final trimmedModel = model.trim();
    final trimmedVin = vin.trim().toUpperCase();

    if (trimmedId.isEmpty) {
      throw ArgumentError('Vehicle ID cannot be empty.');
    }
    if (trimmedPlate.isEmpty) {
      throw ArgumentError('Plate number cannot be empty.');
    }
    if (trimmedBrand.isEmpty) {
      throw ArgumentError('Vehicle brand cannot be empty.');
    }
    if (trimmedModel.isEmpty) {
      throw ArgumentError('Vehicle model cannot be empty.');
    }
    if (trimmedVin.length != 17) {
      throw ArgumentError('VIN must be exactly 17 characters long.');
    }
    if (year < 1900 || year > DateTime.now().year + 1) {
      throw ArgumentError('Invalid manufacturing year: $year.');
    }

    return repository.updateVehicle(
      id: trimmedId,
      plateNumber: trimmedPlate,
      brand: trimmedBrand,
      model: trimmedModel,
      year: year,
      vin: trimmedVin,
      photoUrl: photoUrl?.trim(),
    );
  }

  /// Deletes a vehicle by its unique identifier.
  Future<void> delete(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Vehicle ID cannot be empty.');
    }

    return repository.deleteVehicle(trimmedId);
  }
}
