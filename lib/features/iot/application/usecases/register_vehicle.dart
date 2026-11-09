import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to register a new motor vehicle within the IoT domain.
class RegisterVehicle {
  final IotRepository repository;

  const RegisterVehicle({required this.repository});

  /// Executes vehicle registration after enforcing domain invariants.
  Future<Vehicle> execute({
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
    String? photoUrl,
    String? customerId,
  }) async {
    final trimmedPlate = plateNumber.trim().toUpperCase();
    final trimmedBrand = brand.trim();
    final trimmedModel = model.trim();
    final trimmedVin = vin.trim().toUpperCase();

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

    return repository.registerVehicle(
      plateNumber: trimmedPlate,
      brand: trimmedBrand,
      model: trimmedModel,
      year: year,
      vin: trimmedVin,
      photoUrl: photoUrl?.trim(),
      customerId: customerId?.trim(),
    );
  }
}
