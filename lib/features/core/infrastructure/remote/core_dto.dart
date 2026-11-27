import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';

/// DTO representing an automotive workshop resource with pattern matching validation.
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
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      businessName: (json['businessName'] ?? json['name'] ?? '').toString(),
      brandName: (json['brandName'] ?? '').toString(),
      taxId: (json['taxId'] ?? json['ruc'] ?? '').toString(),
      mileageIntervalConfig:
          (json['mileageIntervalConfig'] as num?)?.toInt() ?? 5000,
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

/// DTO representing a physical branch resource with pattern matching validation.
class BranchDto {
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

  BranchDto({
    required this.id,
    required this.workshopId,
    required this.code,
    required this.name,
    required this.address,
    this.district,
    this.phone,
    this.coverImageUrl,
    this.latitude,
    this.longitude,
    required this.active,
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String id,
          'workshopId': final String workshopId,
          'name': final String name,
          'address': final String address,
        }) {
      return BranchDto(
        id: id,
        workshopId: workshopId,
        code: json['code'] as String? ?? '',
        name: name,
        address: address,
        district: json['district'] as String?,
        phone: json['phone'] as String?,
        coverImageUrl: json['coverImageUrl'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        active: json['active'] as bool? ?? true,
      );
    }
    throw const FormatException('Invalid or missing fields in BranchDto JSON');
  }

  Branch toDomain() {
    return Branch(
      id: id,
      workshopId: workshopId,
      code: code,
      name: name,
      address: address,
      district: district,
      phone: phone,
      coverImageUrl: coverImageUrl,
      latitude: latitude,
      longitude: longitude,
      active: active,
    );
  }
}

/// DTO representing a technical specialty within a workshop catalog.
class WorkshopSpecialtyDto {
  final String id;
  final String workshopId;
  final String name;
  final String code;
  final String? description;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkshopSpecialtyDto({
    required this.id,
    required this.workshopId,
    required this.name,
    required this.code,
    this.description,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkshopSpecialtyDto.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String id,
          'workshopId': final String workshopId,
          'name': final String name,
          'code': final String code,
        }) {
      return WorkshopSpecialtyDto(
        id: id,
        workshopId: workshopId,
        name: name,
        code: code,
        description: json['description'] as String?,
        active: json['active'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );
    }
    throw const FormatException(
      'Invalid or missing fields in WorkshopSpecialtyDto JSON',
    );
  }

  WorkshopSpecialty toDomain() {
    return WorkshopSpecialty(
      id: id,
      workshopId: workshopId,
      name: name,
      code: code,
      description: description,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// DTO representing an audit revision entry for a specialty.
class SpecialtyRevisionHistoryDto {
  final String id;
  final String specialtyId;
  final String fieldName;
  final String? oldValue;
  final String? newValue;
  final String? changedBy;
  final DateTime? changedAt;

  SpecialtyRevisionHistoryDto({
    required this.id,
    required this.specialtyId,
    required this.fieldName,
    this.oldValue,
    this.newValue,
    this.changedBy,
    this.changedAt,
  });

  factory SpecialtyRevisionHistoryDto.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String id,
          'specialtyId': final String specialtyId,
          'fieldName': final String fieldName,
        }) {
      return SpecialtyRevisionHistoryDto(
        id: id,
        specialtyId: specialtyId,
        fieldName: fieldName,
        oldValue: json['oldValue']?.toString(),
        newValue: json['newValue']?.toString(),
        changedBy: json['changedBy']?.toString(),
        changedAt: json['changedAt'] != null
            ? DateTime.tryParse(json['changedAt'].toString())
            : null,
      );
    }
    throw const FormatException(
      'Invalid or missing fields in SpecialtyRevisionHistoryDto JSON',
    );
  }

  SpecialtyRevisionHistory toDomain() {
    return SpecialtyRevisionHistory(
      id: id,
      specialtyId: specialtyId,
      fieldName: fieldName,
      oldValue: oldValue,
      newValue: newValue,
      changedBy: changedBy,
      changedAt: changedAt,
    );
  }
}

/// DTO representing a branch subscription assignment response.
class BranchSubscriptionDto {
  final String id;
  final String branchId;
  final String planId;
  final String billingCycle;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  BranchSubscriptionDto({
    required this.id,
    required this.branchId,
    required this.planId,
    required this.billingCycle,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory BranchSubscriptionDto.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String id,
          'branchId': final String branchId,
          'planId': final String planId,
          'billingCycle': final String billingCycle,
          'status': final String status,
        }) {
      return BranchSubscriptionDto(
        id: id,
        branchId: branchId,
        planId: planId,
        billingCycle: billingCycle,
        status: status,
        startDate: json['startDate'] != null
            ? DateTime.tryParse(json['startDate'].toString())
            : null,
        endDate: json['endDate'] != null
            ? DateTime.tryParse(json['endDate'].toString())
            : null,
      );
    }
    throw const FormatException(
      'Invalid or missing fields in BranchSubscriptionDto JSON',
    );
  }

  BranchSubscription toDomain() {
    return BranchSubscription(
      id: id,
      branchId: branchId,
      planId: planId,
      billingCycle: billingCycle,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// DTO for Owner profile.
class OwnerProfileDto {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String documentType;
  final String documentNumber;
  final String phone;
  final String? profileImageUrl;

  OwnerProfileDto({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
    this.profileImageUrl,
  });

  factory OwnerProfileDto.fromJson(Map<String, dynamic> json) {
    return OwnerProfileDto(
      id: (json['id'] ?? json['ownerId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      documentType: (json['documentType'] ?? 'DNI').toString(),
      documentNumber: (json['documentNumber'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  OwnerProfile toDomain() => OwnerProfile(
        id: id,
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        documentType: documentType,
        documentNumber: documentNumber,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );
}

/// DTO for Employee profile.
class EmployeeProfileDto {
  final String employeeId;
  final String workshopId;
  final String firstName;
  final String lastName;
  final String documentType;
  final String documentNumber;
  final String phone;
  final String? profileImageUrl;

  EmployeeProfileDto({
    required this.employeeId,
    required this.workshopId,
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
    this.profileImageUrl,
  });

  factory EmployeeProfileDto.fromJson(Map<String, dynamic> json) {
    final employeeId = (json['employeeId'] ?? json['id'] ?? '').toString();
    final workshopId = (json['workshopId'] ?? '').toString();
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();
    final documentType = (json['documentType'] ?? 'DNI').toString();
    final documentNumber = (json['documentNumber'] ?? '').toString();
    final phone = (json['phone'] ?? '').toString();

    return EmployeeProfileDto(
      employeeId: employeeId,
      workshopId: workshopId,
      firstName: firstName,
      lastName: lastName,
      documentType: documentType,
      documentNumber: documentNumber,
      phone: phone,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  EmployeeProfile toDomain() => EmployeeProfile(
        employeeId: employeeId,
        workshopId: workshopId,
        firstName: firstName,
        lastName: lastName,
        documentType: documentType,
        documentNumber: documentNumber,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );
}

/// DTO for Customer profile.
class CustomerProfileDto {
  final String customerId;
  final String userId;
  final bool isCorporate;
  final String firstName;
  final String lastName;
  final String? businessName;
  final String documentType;
  final String documentNumber;
  final String phone;
  final String? profileImageUrl;

  CustomerProfileDto({
    required this.customerId,
    required this.userId,
    required this.isCorporate,
    required this.firstName,
    required this.lastName,
    this.businessName,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
    this.profileImageUrl,
  });

  factory CustomerProfileDto.fromJson(Map<String, dynamic> json) {
    return CustomerProfileDto(
      customerId: (json['customerId'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      isCorporate: json['isCorporate'] as bool? ?? false,
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      businessName: json['businessName'] as String?,
      documentType: (json['documentType'] ?? 'DNI').toString(),
      documentNumber: (json['documentNumber'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  CustomerProfile toDomain() => CustomerProfile(
        customerId: customerId,
        userId: userId,
        isCorporate: isCorporate,
        firstName: firstName,
        lastName: lastName,
        businessName: businessName,
        documentType: documentType,
        documentNumber: documentNumber,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );
}

/// DTO representing the unified caller profile context (/api/v1/profiles/me).
class UserProfileContextDto {
  final String userId;
  final List<String> roles;
  final String? profileImageUrl;
  final OwnerProfileDto? owner;
  final EmployeeProfileDto? employee;
  final CustomerProfileDto? customer;

  UserProfileContextDto({
    required this.userId,
    required this.roles,
    this.profileImageUrl,
    this.owner,
    this.employee,
    this.customer,
  });

  factory UserProfileContextDto.fromJson(Map<String, dynamic> json) {
    if (json case {'userId': final String userId}) {
      final rolesList = json['roles'] is List
          ? (json['roles'] as List).map((e) => e.toString()).toList()
          : <String>[];

      final ownerMap = json['owner'];
      final employeeMap = json['employee'];
      final customerMap = json['customer'];

      return UserProfileContextDto(
        userId: userId,
        roles: rolesList,
        profileImageUrl: json['profileImageUrl'] as String?,
        owner: ownerMap is Map<String, dynamic>
            ? OwnerProfileDto.fromJson(ownerMap)
            : null,
        employee: employeeMap is Map<String, dynamic>
            ? EmployeeProfileDto.fromJson(employeeMap)
            : null,
        customer: customerMap is Map<String, dynamic>
            ? CustomerProfileDto.fromJson(customerMap)
            : null,
      );
    }
    throw const FormatException(
      'Invalid or missing userId in UserProfileContextDto JSON',
    );
  }

  UserProfileContext toDomain() {
    return UserProfileContext(
      userId: userId,
      roles: roles,
      profileImageUrl: profileImageUrl,
      owner: owner?.toDomain(),
      employee: employee?.toDomain(),
      customer: customer?.toDomain(),
    );
  }
}

/// DTO representing an entry from `GET /api/v1/branches/catalog`.
class CustomerBranchCatalogDto {
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

  CustomerBranchCatalogDto({
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

  factory CustomerBranchCatalogDto.fromJson(Map<String, dynamic> json) {
    return CustomerBranchCatalogDto(
      branchId: (json['branchId'] ?? json['id'] ?? '').toString(),
      workshopId: (json['workshopId'] ?? '').toString(),
      workshopBrandName: (json['workshopBrandName'] ?? '').toString(),
      workshopBusinessName: (json['workshopBusinessName'] ?? '').toString(),
      branchCode: (json['branchCode'] ?? '').toString(),
      branchName: (json['branchName'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      activeBaysCount: (json['activeBaysCount'] as num?)?.toInt() ?? 0,
      freeBaysToday: (json['freeBaysToday'] as num?)?.toInt() ?? 0,
    );
  }

  CustomerBranchCatalogItem toDomain() {
    return CustomerBranchCatalogItem(
      branchId: branchId,
      workshopId: workshopId,
      workshopBrandName: workshopBrandName,
      workshopBusinessName: workshopBusinessName,
      branchCode: branchCode,
      branchName: branchName,
      address: address,
      phone: phone,
      coverImageUrl: coverImageUrl,
      latitude: latitude,
      longitude: longitude,
      averageRating: averageRating,
      reviewCount: reviewCount,
      activeBaysCount: activeBaysCount,
      freeBaysToday: freeBaysToday,
    );
  }
}
