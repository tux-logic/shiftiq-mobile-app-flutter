/// Domain Entity representing a technical specialty within a workshop.
class WorkshopSpecialty {
  final String id;
  final String workshopId;
  final String name;
  final String code;
  final String? description;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkshopSpecialty({
    required this.id,
    required this.workshopId,
    required this.name,
    required this.code,
    this.description,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });
}

/// Domain Entity recording a modification history entry for a workshop specialty.
class SpecialtyRevisionHistory {
  final String id;
  final String specialtyId;
  final String fieldName;
  final String? oldValue;
  final String? newValue;
  final String? changedBy;
  final DateTime? changedAt;

  const SpecialtyRevisionHistory({
    required this.id,
    required this.specialtyId,
    required this.fieldName,
    this.oldValue,
    this.newValue,
    this.changedBy,
    this.changedAt,
  });
}
