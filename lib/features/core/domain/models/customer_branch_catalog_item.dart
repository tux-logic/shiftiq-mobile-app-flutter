/// Domain model representing an active workshop branch returned by
/// `GET /api/v1/branches/catalog` for B2C customer discovery and scheduling.
class CustomerBranchCatalogItem {
  final String branchId;
  final String workshopId;
  final String workshopBrandName;
  final String workshopBusinessName;
  final String branchCode;
  final String branchName;
  final String address;
  final String phone;
  final String? coverImageUrl;
  final double? latitude;
  final double? longitude;
  final double averageRating;
  final int reviewCount;
  final int activeBaysCount;
  final int freeBaysToday;

  const CustomerBranchCatalogItem({
    required this.branchId,
    required this.workshopId,
    required this.workshopBrandName,
    required this.workshopBusinessName,
    required this.branchCode,
    required this.branchName,
    required this.address,
    required this.phone,
    this.coverImageUrl,
    this.latitude,
    this.longitude,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.activeBaysCount = 0,
    this.freeBaysToday = 0,
  });

  /// Display title prioritizing the workshop commercial brand name.
  String get displayTitle =>
      workshopBrandName.isNotEmpty ? workshopBrandName : branchName;
}
