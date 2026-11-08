import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/electronic_voucher.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/repositories/billing_repository.dart';

class ProcessPaymentCommandService {
  final BillingRepository billingRepository;

  const ProcessPaymentCommandService({
    required this.billingRepository,
  });

  Future<ElectronicVoucher> execute({
    required String voucherId,
    required PaymentMethod paymentMethod,
  }) async {
    if (voucherId.trim().isEmpty) {
      throw ArgumentError('El identificador del comprobante es obligatorio.');
    }
    return billingRepository.processPayment(
      voucherId: voucherId,
      paymentMethod: paymentMethod,
    );
  }
}
