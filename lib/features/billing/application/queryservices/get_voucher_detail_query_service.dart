import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/electronic_voucher.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/repositories/billing_repository.dart';

class GetVoucherDetailQueryService {
  final BillingRepository billingRepository;

  const GetVoucherDetailQueryService({
    required this.billingRepository,
  });

  Future<ElectronicVoucher> execute(String voucherId) {
    if (voucherId.trim().isEmpty) {
      throw ArgumentError('El identificador del comprobante es obligatorio.');
    }
    return billingRepository.getVoucherById(voucherId);
  }
}
