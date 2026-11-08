import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/electronic_voucher.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_type.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/repositories/billing_repository.dart';

class GetVouchersByBranchQueryService {
  final BillingRepository billingRepository;

  const GetVouchersByBranchQueryService({
    required this.billingRepository,
  });

  Future<List<ElectronicVoucher>> execute({
    required String branchId,
    VoucherType? voucherType,
    VoucherStatus? status,
  }) {
    return billingRepository.getVouchers(
      branchId: branchId,
      voucherType: voucherType,
      status: status,
    );
  }
}
