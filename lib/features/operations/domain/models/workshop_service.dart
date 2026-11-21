/// Aggregate entity representing a workshop billable labor service offered by a branch.
class WorkshopService {
  final String id;
  final String branchId;
  final String name;
  final double price;

  const WorkshopService({
    required this.id,
    required this.branchId,
    required this.name,
    required this.price,
  });

  WorkshopService copyWith({
    String? id,
    String? branchId,
    String? name,
    double? price,
  }) {
    return WorkshopService(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkshopService &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          branchId == other.branchId &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => id.hashCode ^ branchId.hashCode ^ name.hashCode ^ price.hashCode;
}
