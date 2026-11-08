/// Domain Entity representing a Workshop (Taller Mecánico)
class Workshop {
  final String id;
  final String ownerId;
  final String businessName;
  final String brandName;
  final String taxId;
  final int mileageIntervalConfig;

  const Workshop({
    required this.id,
    required this.ownerId,
    required this.businessName,
    required this.brandName,
    required this.taxId,
    this.mileageIntervalConfig = 5000,
  });
}

/// Domain Entity representing a physical Workshop Branch (Sede de Taller)
class Branch {
  final String id;
  final String workshopId;
  final String name;
  final String address;
  final String? district;
  final String? phone;
  final bool active;

  const Branch({
    required this.id,
    required this.workshopId,
    required this.name,
    required this.address,
    this.district,
    this.phone,
    this.active = true,
  });
}

