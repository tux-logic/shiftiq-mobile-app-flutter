import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Application use case managing complete lifecycle operations for Owners, Employees, and Customers.
class ManageProfileLifecycle {
  final CoreRepository repository;

  ManageProfileLifecycle({required this.repository});

  // --- Owner Profile Operations ---

  /// Retrieves owner profile by ID.
  Future<Map<String, dynamic>> getOwnerById(String ownerId) {
    if (ownerId.trim().isEmpty) {
      throw ArgumentError('ownerId cannot be empty');
    }
    return repository.getOwnerById(ownerId.trim());
  }

  /// Updates owner contact details.
  Future<Map<String, dynamic>> updateOwnerProfile({
    required String ownerId,
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    if (ownerId.trim().isEmpty) {
      throw ArgumentError('ownerId cannot be empty');
    }
    return repository.updateOwnerProfile(
      ownerId: ownerId.trim(),
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      phone: phone?.trim(),
    );
  }

  /// Deactivates owner profile.
  Future<void> deleteOwnerProfile(String ownerId) {
    if (ownerId.trim().isEmpty) {
      throw ArgumentError('ownerId cannot be empty');
    }
    return repository.deleteOwnerProfile(ownerId.trim());
  }

  // --- Employee Profile Operations ---

  /// Retrieves employee profile by ID.
  Future<Map<String, dynamic>> getEmployeeById(String employeeId) {
    if (employeeId.trim().isEmpty) {
      throw ArgumentError('employeeId cannot be empty');
    }
    return repository.getEmployeeById(employeeId.trim());
  }

  /// Searches employees by DNI document number.
  Future<List<Map<String, dynamic>>> getEmployeesByDocumentNumber(
    String documentNumber,
  ) {
    if (documentNumber.trim().isEmpty) {
      throw ArgumentError('documentNumber cannot be empty');
    }
    return repository.getEmployeesByDocumentNumber(documentNumber.trim());
  }

  /// Updates employee profile personal details.
  Future<Map<String, dynamic>> updateEmployeeProfile({
    required String employeeId,
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    if (employeeId.trim().isEmpty) {
      throw ArgumentError('employeeId cannot be empty');
    }
    return repository.updateEmployeeProfile(
      employeeId: employeeId.trim(),
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      phone: phone?.trim(),
    );
  }

  /// Deactivates employee profile.
  Future<void> deleteEmployeeProfile(String employeeId) {
    if (employeeId.trim().isEmpty) {
      throw ArgumentError('employeeId cannot be empty');
    }
    return repository.deleteEmployeeProfile(employeeId.trim());
  }

  // --- Customer Profile Operations ---

  /// Retrieves customer profile by ID.
  Future<Map<String, dynamic>> getCustomerById(String customerId) {
    if (customerId.trim().isEmpty) {
      throw ArgumentError('customerId cannot be empty');
    }
    return repository.getCustomerById(customerId.trim());
  }

  /// Updates customer profile contact and business details.
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String customerId,
    String? firstName,
    String? lastName,
    String? businessName,
    String? phone,
  }) {
    if (customerId.trim().isEmpty) {
      throw ArgumentError('customerId cannot be empty');
    }
    return repository.updateCustomerProfile(
      customerId: customerId.trim(),
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      businessName: businessName?.trim(),
      phone: phone?.trim(),
    );
  }

  /// Deactivates customer profile.
  Future<void> deleteCustomerProfile(String customerId) {
    if (customerId.trim().isEmpty) {
      throw ArgumentError('customerId cannot be empty');
    }
    return repository.deleteCustomerProfile(customerId.trim());
  }
}
