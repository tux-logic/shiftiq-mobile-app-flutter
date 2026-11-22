import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/spare_part_thumbnail.dart';

/// Redesigned task card for [WorkOrderDetailPage] featuring a status badge,
/// full-width title, mechanic chip, spare-part thumbnails, and role-gated actions.
class WorkOrderTaskCard extends StatelessWidget {
  final WorkOrderTask task;
  final bool canExecute;
  final bool orderCompleted;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onAddProduct;

  const WorkOrderTaskCard({
    super.key,
    required this.task,
    required this.canExecute,
    required this.orderCompleted,
    required this.onTap,
    required this.onStart,
    required this.onComplete,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final statusColor = task.isCompleted
        ? ShiftIQColors.preventiveGreen
        : task.isInProgress
            ? ShiftIQColors.secondaryTeal
            : ShiftIQColors.severityAmber;
    final statusLabel = task.isCompleted
        ? 'Completada'
        : task.isInProgress
            ? 'En progreso'
            : 'Pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? ShiftIQColors.preventiveGreen.withAlpha(90)
              : ShiftIQColors.borderSlate,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Status pill + Price + Chevron
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(24),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.check_circle_rounded
                                : task.isInProgress
                                    ? Icons.autorenew_rounded
                                    : Icons.schedule_rounded,
                            size: 13,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'S/ ${task.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Full-width description
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ShiftIQColors.graphiteText,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 8),

                // Mechanic & Parts summary chip
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ShiftIQColors.warmNeutral,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ShiftIQColors.borderSlate.withAlpha(140),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.engineering_outlined,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              task.assignedMechanicName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ShiftIQColors.graphiteText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (task.products.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: ShiftIQColors.primaryBlue.withAlpha(12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${task.products.length} ${task.products.length == 1 ? 'repuesto' : 'repuestos'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ShiftIQColors.primaryBlue,
                          ),
                        ),
                      ),
                  ],
                ),

                // Attached spare parts preview with thumbnails
                if (task.products.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ShiftIQColors.warmNeutral,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ShiftIQColors.borderSlate.withAlpha(140),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < task.products.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 12,
                              color: ShiftIQColors.borderSlate.withAlpha(120),
                            ),
                          _TaskProductPreviewRow(product: task.products[i]),
                        ],
                      ],
                    ),
                  ),
                ],

                // Action Bar
                if (!task.isCompleted && !canExecute) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Asignada a otro técnico',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ] else if (!task.isCompleted && canExecute) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (task.isPending)
                        OutlinedButton.icon(
                          onPressed: onStart,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ShiftIQColors.primaryBlue,
                            side: const BorderSide(
                              color: ShiftIQColors.primaryBlue,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: Text(
                            loc.translate('start'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (task.isInProgress)
                        ElevatedButton.icon(
                          onPressed: onComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ShiftIQColors.secondaryTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text(
                            loc.translate('complete'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (!orderCompleted)
                        OutlinedButton.icon(
                          onPressed: onAddProduct,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ShiftIQColors.graphiteText,
                            side: const BorderSide(
                              color: ShiftIQColors.borderSlate,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                          ),
                          label: Text(
                            loc.translate('add_part_btn'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskProductPreviewRow extends StatelessWidget {
  final WorkOrderTaskProduct product;

  const _TaskProductPreviewRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SparePartThumbnail(
          imageUrl: product.imageUrl,
          size: 32,
          borderRadius: 8,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            product.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ShiftIQColors.graphiteText,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ShiftIQColors.borderSlate),
          ),
          child: Text(
            'x${product.quantity}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ShiftIQColors.graphiteText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          product.formattedTotal,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ShiftIQColors.primaryBlue,
          ),
        ),
      ],
    );
  }
}
