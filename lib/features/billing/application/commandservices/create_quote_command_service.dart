import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/quote.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/repositories/billing_repository.dart';

class CreateQuoteCommandService {
  final BillingRepository billingRepository;

  const CreateQuoteCommandService({
    required this.billingRepository,
  });

  Future<Quote> execute({
    required String branchId,
    String? workOrderId,
    required String customerName,
    required String customerPhone,
    required String vehiclePlate,
    required String vehicleModel,
    required List<VoucherItem> items,
    required DateTime validUntil,
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('La sede es obligatoria.');
    }
    if (customerName.trim().isEmpty) {
      throw ArgumentError('El nombre del cliente es obligatorio.');
    }
    if (vehiclePlate.trim().isEmpty) {
      throw ArgumentError('La placa del vehículo es obligatoria.');
    }
    if (items.isEmpty) {
      throw ArgumentError('Debe incluir al menos un ítem o servicio a cotizar.');
    }

    return billingRepository.createQuote(
      branchId: branchId,
      workOrderId: workOrderId,
      customerName: customerName,
      customerPhone: customerPhone,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      items: items,
      validUntil: validUntil,
    );
  }
}
