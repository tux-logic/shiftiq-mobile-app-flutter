import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Application use case managing status updates and deactivations for customer branch registrations.
class ManageCustomerRegistrationStatus {
  final FleetRepository repository;

  static const Set<String> validStatuses = {
    'ACTIVE',
    'INACTIVE',
    'BLACKLISTED',
  };

  ManageCustomerRegistrationStatus({required this.repository});

  /// Updates registration status with optional audit reason.
  Future<CustomerRegistration> updateStatus({
    required String registrationId,
    required String status,
    String? reason,
  }) async {
    final trimmedId = registrationId.trim();
    if (trimmedId.isEmpty) {
      throw ValidationException(message: 'Registration ID cannot be empty');
    }

    final normalizedStatus = status.trim().toUpperCase();
    if (!validStatuses.contains(normalizedStatus)) {
      throw ValidationException(
        message:
            'Invalid registration status "$status". Allowed statuses: ${validStatuses.join(', ')}',
      );
    }

    if (normalizedStatus == 'BLACKLISTED' &&
        (reason == null || reason.trim().isEmpty)) {
      throw ValidationException(
        message: 'A reason must be provided when blacklisting a customer.',
      );
    }

    return repository.updateCustomerRegistrationStatus(
      registrationId: trimmedId,
      status: normalizedStatus,
      reason: reason?.trim(),
    );
  }

  /// Convenience method to blacklist a customer branch registration.
  Future<CustomerRegistration> blacklistCustomer({
    required String registrationId,
    required String reason,
  }) {
    return updateStatus(
      registrationId: registrationId,
      status: 'BLACKLISTED',
      reason: reason,
    );
  }

  /// Convenience method to activate an inactive or blacklisted registration.
  Future<CustomerRegistration> activateCustomer(String registrationId) {
    return updateStatus(
      registrationId: registrationId,
      status: 'ACTIVE',
    );
  }

  /// Removes/deactivates a customer branch registration.
  Future<void> deactivateRegistration(String registrationId) async {
    final trimmedId = registrationId.trim();
    if (trimmedId.isEmpty) {
      throw ValidationException(message: 'Registration ID cannot be empty');
    }
    return repository.deleteCustomerRegistration(trimmedId);
  }
}
