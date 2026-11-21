/// Domain Entity representing a physical workshop branch.
class Branch {
  final String id;
  final String workshopId;
  final String code;
  final String name;
  final String address;
  final String? district;
  final String? phone;
  final String? coverImageUrl;
  final double? latitude;
  final double? longitude;
  final bool active;

  const Branch({
    required this.id,
    required this.workshopId,
    this.code = '',
    required this.name,
    required this.address,
    this.district,
    this.phone,
    this.coverImageUrl,
    this.latitude,
    this.longitude,
    this.active = true,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
}
