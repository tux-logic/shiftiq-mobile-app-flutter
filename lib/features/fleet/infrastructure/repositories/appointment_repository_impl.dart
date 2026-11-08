import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/entities/customer_registration.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/appointment_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/appointment_api.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentApi appointmentApi;

  final List<Appointment> _localAppointments = [];
  final List<CustomerRegistration> _localCustomers = [];

  AppointmentRepositoryImpl({required this.appointmentApi}) {
    _initDemoData();
  }

  void _initDemoData() {
    if (_localAppointments.isNotEmpty) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _localAppointments.addAll([
      Appointment(
        id: 'apt-01',
        branchId: 'b-01-smp',
        customerId: 'cust-01',
        customerName: 'Martín Vizcarra',
        customerPhone: '+51 999 111 222',
        vehicleId: 'veh-01',
        vehiclePlate: 'B8C-456',
        vehicleModel: 'Nissan Sentra 2020',
        scheduledStart: today.add(const Duration(hours: 9, minutes: 0)),
        serviceType: 'Mantenimiento Preventivo 30,000 km',
        notes: 'Cliente solicita revisión general de niveles e inspección de suspensión',
        status: AppointmentStatus.confirmed,
        bayNumber: 1,
        createdAt: today.subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: 'apt-02',
        branchId: 'b-01-smp',
        customerId: 'cust-02',
        customerName: 'Andrea Benavente',
        customerPhone: '+51 988 333 444',
        vehicleId: 'veh-02',
        vehiclePlate: 'F1G-789',
        vehicleModel: 'Kia Sportage 2022',
        scheduledStart: today.add(const Duration(hours: 11, minutes: 30)),
        serviceType: 'Diagnóstico Computarizado OBD-II',
        notes: 'Testigo Check Engine intermitente en tablero (código P0300 sospechado)',
        status: AppointmentStatus.pending,
        bayNumber: 3,
        createdAt: today.subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: 'apt-03',
        branchId: 'b-01-smp',
        customerId: 'cust-03',
        customerName: 'Roberto Gómez',
        customerPhone: '+51 977 555 666',
        vehicleId: 'veh-03',
        vehiclePlate: 'C4D-123',
        vehicleModel: 'Toyota Yaris 2018',
        scheduledStart: today.add(const Duration(hours: 15, minutes: 0)),
        serviceType: 'Cambio de Pastillas de Freno',
        notes: 'Sonido chirriante al frenar en baja velocidad',
        status: AppointmentStatus.confirmed,
        bayNumber: 2,
        createdAt: today.subtract(const Duration(hours: 18)),
      ),
      Appointment(
        id: 'apt-04',
        branchId: 'b-01-smp',
        customerId: 'cust-04',
        customerName: 'Carlos Mendoza',
        customerPhone: '+51 987 654 321',
        vehicleId: 'veh-04',
        vehiclePlate: 'BCX-892',
        vehicleModel: 'Toyota Hilux 2021',
        scheduledStart: today.add(const Duration(hours: 17, minutes: 0)),
        serviceType: 'Mantenimiento de Frenos y Cambio DOT4',
        notes: 'Atendida exitosamente en Bahía 2',
        status: AppointmentStatus.completed,
        bayNumber: 1,
        createdAt: today.subtract(const Duration(days: 3)),
      ),
    ]);

    _localCustomers.addAll([
      const CustomerRegistration(
        id: 'reg-01',
        branchId: 'b-01-smp',
        customerId: 'cust-01',
        customerName: 'Martín Vizcarra',
        phone: '+51 999 111 222',
        email: 'martin.vizcarra@gmail.com',
        vehiclePlate: 'B8C-456',
        vehicleModel: 'Nissan Sentra 2020',
      ),
      const CustomerRegistration(
        id: 'reg-02',
        branchId: 'b-01-smp',
        customerId: 'cust-02',
        customerName: 'Andrea Benavente',
        phone: '+51 988 333 444',
        email: 'andrea.benavente@outlook.com',
        vehiclePlate: 'F1G-789',
        vehicleModel: 'Kia Sportage 2022',
      ),
      const CustomerRegistration(
        id: 'reg-03',
        branchId: 'b-01-smp',
        customerId: 'cust-03',
        customerName: 'Roberto Gómez',
        phone: '+51 977 555 666',
        email: 'roberto.gomez@gmail.com',
        vehiclePlate: 'C4D-123',
        vehicleModel: 'Toyota Yaris 2018',
      ),
      const CustomerRegistration(
        id: 'reg-04',
        branchId: 'b-01-smp',
        customerId: 'cust-04',
        customerName: 'Carlos Mendoza',
        phone: '+51 987 654 321',
        email: 'carlos.mendoza@castromotors.pe',
        vehiclePlate: 'BCX-892',
        vehicleModel: 'Toyota Hilux 2021',
      ),
    ]);
  }

  @override
  Future<List<Appointment>> getAppointments({
    required String branchId,
    DateTime? date,
    AppointmentStatus? status,
  }) async {
    try {
      final remoteDtos = await appointmentApi.getAppointments(
        branchId: branchId,
        status: status?.value,
      );
      if (remoteDtos.isNotEmpty) {
        return remoteDtos.map((dto) => dto.toDomain()).toList();
      }
    } catch (_) {
      // Fallback to local store
    }

    var list = _localAppointments
        .where((apt) => apt.branchId == branchId || branchId.isEmpty)
        .toList();

    if (date != null) {
      list = list.where((apt) {
        return apt.scheduledStart.year == date.year &&
            apt.scheduledStart.month == date.month &&
            apt.scheduledStart.day == date.day;
      }).toList();
    }

    if (status != null) {
      list = list.where((apt) => apt.status == status).toList();
    }

    list.sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
    return list;
  }

  @override
  Future<Appointment> getAppointmentById(String id) async {
    try {
      final dto = await appointmentApi.getAppointmentById(id);
      return dto.toDomain();
    } catch (_) {
      // Fallback
    }

    return _localAppointments.firstWhere(
      (apt) => apt.id == id,
      orElse: () => _localAppointments.first,
    );
  }

  @override
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
  }) async {
    try {
      final dto = await appointmentApi.createAppointment(
        branchId: branchId,
        customerId: customerId,
        vehicleId: vehicleId,
        scheduledStart: scheduledStart,
        serviceType: serviceType,
        notes: notes,
      );
      final domain = dto.toDomain(
        customerName: customerName,
        customerPhone: customerPhone,
        vehiclePlate: vehiclePlate,
        vehicleModel: vehicleModel,
        bayNumber: bayNumber,
      );
      _localAppointments.add(domain);
      return domain;
    } catch (_) {
      // Fallback local creation
    }

    final newApt = Appointment(
      id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      vehicleId: vehicleId,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      scheduledStart: scheduledStart,
      serviceType: serviceType,
      notes: notes,
      status: AppointmentStatus.pending,
      bayNumber: bayNumber,
      createdAt: DateTime.now(),
    );

    _localAppointments.add(newApt);
    return newApt;
  }

  @override
  Future<Appointment> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
  }) async {
    try {
      final dto = await appointmentApi.updateAppointmentStatus(
        id: id,
        status: status.value,
      );
      return dto.toDomain();
    } catch (_) {
      // Fallback mutation
    }

    final index = _localAppointments.indexWhere((apt) => apt.id == id);
    if (index >= 0) {
      final current = _localAppointments[index];
      final updated = Appointment(
        id: current.id,
        branchId: current.branchId,
        customerId: current.customerId,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        vehicleId: current.vehicleId,
        vehiclePlate: current.vehiclePlate,
        vehicleModel: current.vehicleModel,
        scheduledStart: current.scheduledStart,
        serviceType: current.serviceType,
        notes: current.notes,
        status: status,
        bayNumber: current.bayNumber,
        createdAt: current.createdAt,
      );

      _localAppointments[index] = updated;
      return updated;
    }

    throw Exception('Appointment not found');
  }

  @override
  Future<List<CustomerRegistration>> getCustomerDirectory(
    String branchId,
  ) async {
    try {
      final dtos = await appointmentApi.getCustomerRegistrations(branchId);
      if (dtos.isNotEmpty) {
        return dtos.map((d) => d.toDomain()).toList();
      }
    } catch (_) {
      // Fallback
    }

    return _localCustomers
        .where((c) => c.branchId == branchId || branchId.isEmpty)
        .toList();
  }
}
