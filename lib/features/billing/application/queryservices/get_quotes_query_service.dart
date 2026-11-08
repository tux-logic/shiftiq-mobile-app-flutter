import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/aggregates/quote.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/repositories/billing_repository.dart';

class GetQuotesQueryService {
  final BillingRepository billingRepository;

  const GetQuotesQueryService({
    required this.billingRepository,
  });

  Future<List<Quote>> execute({required String branchId}) {
    return billingRepository.getQuotes(branchId: branchId);
  }
}
