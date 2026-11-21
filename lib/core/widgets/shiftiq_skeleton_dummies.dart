import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/models/branch_analytics_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/models/aggregates/branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/entities/customer_registration.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/models/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/models/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/models/work_order_status.dart';

/// Placeholder domain instances passed into real UI widgets when wrapped
/// with `Skeletonizer` (`ShiftIQSkeletonizer`) during loading states.
class ShiftIQSkeletonDummies {
  ShiftIQSkeletonDummies._();

  static final DateTime _anchorDate = DateTime(2026, 1, 15, 10, 30);

  static List<WorkOrder> workOrders({int count = 4}) => List.generate(
        count,
        (i) => WorkOrder(
          id: 'skel-wo-$i',
          appointmentId: 'skel-appt-$i',
          branchId: 'skel-branch',
          vehicleId: 'skel-veh-$i',
          vehiclePlate: 'ABC-123',
          vehicleModel: 'Toyota Corolla 2022',
          customerId: 'skel-cust-$i',
          customerName: 'Carlos Mendoza Pérez',
          internalNumber: 100 + i,
          formattedNumber: 'OT-0010$i',
          status: WorkOrderStatus.inProgress,
          diagnosticSummary: 'Mantenimiento preventivo y revisión general',
          mileageIn: 45200,
          totalAmount: 480.00,
          createdAt: _anchorDate,
        ),
      );

  static List<Appointment> appointments({int count = 4}) => List.generate(
        count,
        (i) => Appointment(
          id: 'skel-appt-$i',
          branchId: 'skel-branch',
          customerId: 'skel-cust-$i',
          customerName: 'Carlos Mendoza Pérez',
          vehicleId: 'skel-veh-$i',
          vehiclePlate: 'ABC-123',
          vehicleModel: 'Toyota Corolla 2022',
          scheduledStart: _anchorDate.add(Duration(hours: i)),
          serviceType: 'Mantenimiento preventivo',
          status: AppointmentStatus.confirmed,
          bayNumber: (i % 3) + 1,
        ),
      );

  static List<CustomerRegistration> customers({int count = 5}) => List.generate(
        count,
        (i) => CustomerRegistration(
          id: 'skel-reg-$i',
          branchId: 'skel-branch',
          customerId: 'skel-cust-$i',
          customerName: 'Carlos Mendoza Pérez',
          phone: '999 888 777',
          email: 'cliente@taller.com',
          vehiclePlate: 'ABC-123',
          vehicleModel: 'Toyota Corolla 2022',
        ),
      );

  static List<Product> products({int count = 4}) => List.generate(
        count,
        (i) => Product(
          id: 'skel-prod-$i',
          branchId: 'skel-branch',
          sku: 'SKU-00$i',
          name: 'Filtro de Aceite Sintético',
          category: 'Filtros',
          unitOfMeasure: 'UND',
          salePrice: 65.00,
          costPrice: 38.00,
          currentStock: 18,
          minimumStock: 5,
        ),
      );

  static List<DtcAlert> dtcAlerts({int count = 4}) => List.generate(
        count,
        (i) => DtcAlert(
          id: 'skel-dtc-$i',
          branchId: 'skel-branch',
          vehicleId: 'skel-veh-$i',
          vehiclePlate: 'ABC-123',
          vehicleModel: 'Hyundai Tucson 2021',
          customerName: 'Carlos Mendoza',
          code: 'P0300',
          description: 'Fallo de encendido múltiple detectado en cilindros',
          systemCategory: 'Powertrain',
          severity: DtcSeverity.values.first,
          aiDiagnosticRecommendation: 'Revisar bujías y bobinas de encendido',
          detectedAt: _anchorDate,
        ),
      );

  static List<ElectronicVoucher> vouchers({int count = 3}) => List.generate(
        count,
        (i) => ElectronicVoucher(
          id: 'skel-v-$i',
          branchId: 'skel-branch',
          voucherType: VoucherType.boleta,
          customerDocumentType: 'DNI',
          customerDocumentNumber: '45678901',
          customerName: 'Carlos Mendoza Pérez',
          totalAmount: 320.00,
          status: VoucherStatus.paid,
          series: 'B001',
          correlative: '00001$i',
          issuedAt: _anchorDate,
        ),
      );

  static List<Quote> quotes({int count = 3}) => List.generate(
        count,
        (i) => Quote(
          id: 'skel-q-$i',
          branchId: 'skel-branch',
          quoteNumber: 'COT-001$i',
          customerName: 'Carlos Mendoza Pérez',
          vehiclePlate: 'ABC-123',
          vehicleModel: 'Toyota Corolla 2022',
          totalAmount: 450.00,
          status: QuoteStatus.approved,
          validUntil: _anchorDate.add(const Duration(days: 7)),
        ),
      );

  static List<Branch> branches({int count = 3}) => List.generate(
        count,
        (i) => Branch(
          id: 'skel-b-$i',
          workshopId: 'skel-ws',
          code: 'LIM-0$i',
          name: 'Sede Principal ShiftIQ',
          address: 'Av. Javier Prado Este 4200, Surco',
          phone: '01 445 8899',
        ),
      );

  static const BranchAnalyticsSummary analyticsSummary = BranchAnalyticsSummary(
    branchId: 'skel-branch',
    totalRevenue: 12450.00,
    completedWorkOrdersCount: 24,
    totalAppointmentsCount: 16,
    lowStockAlertsCount: 3,
    dtcAlertsCount: 2,
  );
}
