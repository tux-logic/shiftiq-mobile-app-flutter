/// Entity representing a registered customer motor vehicle in the IoT domain.
class Vehicle {
  final String id;
  final String plateNumber;
  final String brand;
  final String model;
  final int year;
  final String vin;
  final String? photoUrl;
  final String? customerId;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.vin,
    this.photoUrl,
    this.customerId,
  });

  String get displayName => '$brand $model ($year)';

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    String? brand,
    String? model,
    int? year,
    String? vin,
    String? photoUrl,
    String? customerId,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      photoUrl: photoUrl ?? this.photoUrl,
      customerId: customerId ?? this.customerId,
    );
  }
}
