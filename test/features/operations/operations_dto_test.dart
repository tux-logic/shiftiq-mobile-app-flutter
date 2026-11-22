import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/dtos/operations_dto.dart';

void main() {
  test('workOrderFromJson maps vehiclePlateNumber, brand, model, year, and customerName', () {
    final order = OperationsDto.workOrderFromJson({
      'id': 'wo-1',
      'appointmentId': 'appt-1',
      'branchId': 'branch-1',
      'vehicleId': 'veh-1',
      'vehiclePlateNumber': 'B5K-412',
      'vehicleBrand': 'Toyota',
      'vehicleModel': 'Corolla',
      'vehicleYear': 2022,
      'customerId': 'cust-1',
      'customerName': 'ALAN JAIVI MAMANI VILCA',
      'internalNumber': 1,
      'formattedNumber': 'BR-MIRA-01-000001',
      'status': 'PENDING',
      'diagnosticSummary': 'Mantenimiento preventivo',
      'mileageIn': 35000,
      'totalAmount': 150.0,
      'tasks': const [],
      'entryInspectionImages': const [],
    });

    expect(order.vehiclePlate, 'B5K-412');
    expect(order.vehicleModel, 'Toyota Corolla 2022');
    expect(order.customerName, 'ALAN JAIVI MAMANI VILCA');
  });

  test('workOrderFromJson falls back cleanly when enrichment fields are absent', () {
    final order = OperationsDto.workOrderFromJson({
      'id': 'wo-2',
      'appointmentId': 'appt-2',
      'branchId': 'branch-1',
      'vehicleId': 'veh-2',
      'customerId': 'cust-2',
      'internalNumber': 2,
      'formattedNumber': 'BR-MIRA-01-000002',
      'status': 'PENDING',
      'diagnosticSummary': 'Check brakes',
      'mileageIn': 12000,
      'totalAmount': 0,
    });

    expect(order.vehiclePlate, 'S/P');
    expect(order.vehicleModel, 'Vehículo General');
    expect(order.customerName, 'Cliente General');
  });

  test('workOrderTaskProductFromJson maps productName when present and falls back otherwise', () {
    final named = OperationsDto.workOrderTaskProductFromJson({
      'id': 'tp-1',
      'productId': 'prod-1',
      'productName': 'Filtro de Aceite Bosch',
      'branchId': 'branch-1',
      'quantity': 2,
      'unitPrice': 45.0,
      'totalAmount': 90.0,
    });
    expect(named.productName, 'Filtro de Aceite Bosch');

    final unnamed = OperationsDto.workOrderTaskProductFromJson({
      'id': 'tp-2',
      'productId': 'prod-2',
      'branchId': 'branch-1',
      'quantity': 1,
      'unitPrice': 20.0,
      'totalAmount': 20.0,
    });
    expect(unnamed.productName, 'Repuesto');
  });
}
