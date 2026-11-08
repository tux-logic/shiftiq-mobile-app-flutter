import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/entities/customer_registration.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/appointment_repository.dart';

class GetCustomerDirectoryQueryService {
  final AppointmentRepository appointmentRepository;

  const GetCustomerDirectoryQueryService({
    required this.appointmentRepository,
  });

  Future<List<CustomerRegistration>> execute({
    required String branchId,
    String? searchQuery,
  }) async {
    return appointmentRepository.getCustomerRegistrations(
      branchId: branchId,
      query: searchQuery,
    );
  }
}
