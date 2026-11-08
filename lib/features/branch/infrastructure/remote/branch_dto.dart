import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch.dart';

class WorkshopDto {
  final String id;
  final String ownerId;
  final String businessName;
  final String brandName;
  final String taxId;
  final int mileageIntervalConfig;

  WorkshopDto({
    required this.id,
    required this.ownerId,
    required this.businessName,
    required this.brandName,
    required this.taxId,
    required this.mileageIntervalConfig,
  });

  factory WorkshopDto.fromJson(Map<String, dynamic> json) {
    return WorkshopDto(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      taxId: json['taxId'] as String? ?? '',
      mileageIntervalConfig: (json['mileageIntervalConfig'] as num?)?.toInt() ?? 5000,
    );
  }

  Workshop toDomain() {
    return Workshop(
      id: id,
      ownerId: ownerId,
      businessName: businessName,
      brandName: brandName,
      taxId: taxId,
      mileageIntervalConfig: mileageIntervalConfig,
    );
  }
}

class BranchDto {
  final String id;
  final String workshopId;
  final String name;
  final String address;
  final String? district;
  final String? phone;
  final bool active;

  BranchDto({
    required this.id,
    required this.workshopId,
    required this.name,
    required this.address,
    this.district,
    this.phone,
    required this.active,
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) {
    return BranchDto(
      id: json['id'] as String? ?? '',
      workshopId: json['workshopId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      district: json['district'] as String?,
      phone: json['phone'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  Branch toDomain() {
    return Branch(
      id: id,
      workshopId: workshopId,
      name: name,
      address: address,
      district: district,
      phone: phone,
      active: active,
    );
  }
}
