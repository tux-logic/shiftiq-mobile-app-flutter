/// Domain Entity representing a physical workshop branch (sede de taller).
class Branch {
  final String id;
  final String workshopId;
  final String code;
  final String name;
  final String address;
  final String? district;
  final String? phone;
  final bool active;

  const Branch({
    required this.id,
    required this.workshopId,
    this.code = '',
    required this.name,
    required this.address,
    this.district,
    this.phone,
    this.active = true,
  });
}
