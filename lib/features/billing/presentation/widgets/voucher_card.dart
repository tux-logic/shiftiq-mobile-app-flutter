import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';

/// Minimalist ShiftIQ card representing an issued SUNAT electronic voucher.
class VoucherCard extends StatelessWidget {
  final ElectronicVoucher voucher;
  final VoidCallback onTap;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = voucher.status == VoucherStatus.paid;
    final isFactura = voucher.voucherType == VoucherType.factura;
    final statusColor =
        isPaid ? ShiftIQColors.preventiveGreen : ShiftIQColors.severityOrange;
    final typeColor =
        isFactura ? ShiftIQColors.primaryBlue : ShiftIQColors.secondaryTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        voucher.series,
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        voucher.fullCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        voucher.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  voucher.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${voucher.customerDocumentType}: ${voucher.customerDocumentNumber}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${voucher.issuedAt.day.toString().padLeft(2, '0')}/${voucher.issuedAt.month.toString().padLeft(2, '0')} ${voucher.issuedAt.hour.toString().padLeft(2, '0')}:${voucher.issuedAt.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: ShiftIQColors.borderSlate.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${voucher.items.length} ítems facturados',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'S/ ${voucher.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: isPaid
                            ? ShiftIQColors.preventiveGreen
                            : ShiftIQColors.graphiteText,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
