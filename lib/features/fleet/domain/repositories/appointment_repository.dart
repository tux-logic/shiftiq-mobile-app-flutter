import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/entities/customer_registration.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments({
    required String branchId,
    DateTime? date,
    AppointmentStatus? status,
  });

  Future<Appointment> getAppointmentById(String id);

  Future<Appointment> createAppointment({
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    String serviceType = 'Mantenimiento General',
    String notes = '',
    String customerName = 'Cliente del Taller',
    String customerPhone = '',
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    int bayNumber = 1,
  });

  Future<Appointment> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
  });

  Future<List<CustomerRegistration>> getCustomerDirectory(String branchId);
}
