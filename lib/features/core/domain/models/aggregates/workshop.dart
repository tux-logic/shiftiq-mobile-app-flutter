/// Domain Aggregate Root representing an automotive workshop (taller mecánico).
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
