import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/dtos/quote_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/dtos/voucher_dto.dart';

class BillingApi {
  final ApiClient apiClient;

  BillingApi({required this.apiClient});

  Future<List<VoucherDto>> getVouchers({
    required String branchId,
    String? voucherType,
    String? status,
  }) async {
    var url = '/api/v1/vouchers?branchId=$branchId';
    if (voucherType != null && voucherType.isNotEmpty) {
      url += '&voucherType=$voucherType';
    }
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    final response = await apiClient.get(url);
    if (response is List) {
      return response
          .map((item) => VoucherDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<VoucherDto> getVoucherById(String id) async {
    final response = await apiClient.get('/api/v1/vouchers/$id');
    return VoucherDto.fromJson(response as Map<String, dynamic>);
  }

  Future<VoucherDto> emitVoucher(Map<String, dynamic> body) async {
    final response = await apiClient.post('/api/v1/vouchers', body: body);
    return VoucherDto.fromJson(response as Map<String, dynamic>);
  }

  Future<VoucherDto> processPayment(
    String voucherId,
    Map<String, dynamic> body,
  ) async {
    final response = await apiClient.post(
      '/api/v1/vouchers/$voucherId/checkout',
      body: body,
    );
    return VoucherDto.fromJson(response as Map<String, dynamic>);
  }

  Future<List<QuoteDto>> getQuotes({required String branchId}) async {
    final response = await apiClient.get('/api/v1/quotes?branchId=$branchId');
    if (response is List) {
      return response
          .map((item) => QuoteDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<QuoteDto> createQuote(Map<String, dynamic> body) async {
    final response = await apiClient.post('/api/v1/quotes', body: body);
    return QuoteDto.fromJson(response as Map<String, dynamic>);
  }
}
