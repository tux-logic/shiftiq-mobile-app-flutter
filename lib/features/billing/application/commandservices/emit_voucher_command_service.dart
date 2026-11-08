import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/electronic_voucher.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/tax_document.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_type.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/repositories/billing_repository.dart';

class EmitVoucherCommandService {
  final BillingRepository billingRepository;

  const EmitVoucherCommandService({
    required this.billingRepository,
  });

  Future<ElectronicVoucher> execute({
    required String branchId,
    required String workOrderId,
    required VoucherType voucherType,
    required String customerDocumentType,
    required String customerDocumentNumber,
    required String customerName,
    String? customerAddress,
    required PaymentMethod paymentMethod,
    required List<VoucherItem> items,
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('La sede emisora es obligatoria.');
    }
    if (workOrderId.trim().isEmpty) {
      throw ArgumentError('La orden de trabajo asociada es obligatoria.');
    }
    if (customerName.trim().isEmpty) {
      throw ArgumentError('La razón social o nombre del cliente es obligatorio.');
    }
    if (items.isEmpty) {
      throw ArgumentError('Debe incluir al menos un ítem o servicio a facturar.');
    }

    final taxDoc = TaxDocument(
      type: customerDocumentType,
      number: customerDocumentNumber,
    );
    final docError = taxDoc.validate();
    if (docError != null) {
      throw ArgumentError(docError);
    }

    if (voucherType == VoucherType.factura && customerDocumentType != 'RUC') {
      throw ArgumentError('Para emitir Factura Electrónica se requiere RUC de 11 dígitos.');
    }

    return billingRepository.emitVoucher(
      branchId: branchId,
      workOrderId: workOrderId,
      voucherType: voucherType,
      customerDocumentType: customerDocumentType,
      customerDocumentNumber: customerDocumentNumber,
      customerName: customerName,
      customerAddress: customerAddress,
      paymentMethod: paymentMethod,
      items: items,
    );
  }
}
