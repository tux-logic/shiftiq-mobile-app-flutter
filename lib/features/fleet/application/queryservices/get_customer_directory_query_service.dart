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
    final customers = await appointmentRepository.getCustomerDirectory(branchId);
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      return customers.where((c) {
        return c.customerName.toLowerCase().contains(q) ||
            c.vehiclePlate.toLowerCase().contains(q) ||
            c.phone.contains(q);
      }).toList();
    }
    return customers;
  }
}
