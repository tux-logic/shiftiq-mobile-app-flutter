import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/spare_part_thumbnail.dart';

/// Modal bottom sheet displaying full task details: status, timestamps,
/// labor/parts cost breakdown, consumed spare parts, and evidence images.
class TaskDetailSheet extends StatelessWidget {
  final WorkOrderTask task;
  final VoidCallback? onAddProduct;
  final VoidCallback? onStartTask;
  final VoidCallback? onCompleteTask;

  const TaskDetailSheet({
    super.key,
    required this.task,
    this.onAddProduct,
    this.onStartTask,
    this.onCompleteTask,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$min';
  }

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

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ShiftIQColors.graphiteText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: ShiftIQColors.borderSlate),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mechanic & Timestamps
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ShiftIQColors.warmNeutral,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ShiftIQColors.borderSlate),
                      ),
                      child: Column(
                        children: [
                          _MetaRow(
                            icon: Icons.engineering_outlined,
                            label: 'Mecánico',
                            value: task.assignedMechanicName,
                          ),
                          if (task.createdAt != null) ...[
                            const SizedBox(height: 8),
                            _MetaRow(
                              icon: Icons.schedule_rounded,
                              label: 'Creada',
                              value: _formatDate(task.createdAt),
                            ),
                          ],
                          if (task.startedAt != null) ...[
                            const SizedBox(height: 8),
                            _MetaRow(
                              icon: Icons.play_circle_outline_rounded,
                              label: 'Iniciada',
                              value: _formatDate(task.startedAt),
                            ),
                          ],
                          if (task.completedAt != null) ...[
                            const SizedBox(height: 8),
                            _MetaRow(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Completada',
                              value: _formatDate(task.completedAt),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Spare parts section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Repuestos (${task.products.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ShiftIQColors.graphiteText,
                          ),
                        ),
                        if (onAddProduct != null &&
                            !task.isCompleted &&
                            task.products.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onAddProduct!();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: ShiftIQColors.primaryBlue,
                              backgroundColor:
                                  ShiftIQColors.primaryBlue.withAlpha(18),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text(
                              'Agregar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (task.products.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ShiftIQColors.borderSlate),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'No hay repuestos asignados a esta tarea.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            if (onAddProduct != null && !task.isCompleted) ...[
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onAddProduct!();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: ShiftIQColors.primaryBlue,
                                  backgroundColor:
                                      ShiftIQColors.primaryBlue.withAlpha(18),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 17),
                                label: const Text(
                                  'Agregar repuesto',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ShiftIQColors.borderSlate),
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < task.products.length; i++) ...[
                              if (i > 0)
                                const Divider(
                                  height: 1,
                                  color: ShiftIQColors.borderSlate,
                                ),
                              _ProductLineTile(product: task.products[i]),
                            ],
                          ],
                        ),
                      ),

                    if (task.evidenceImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Evidencia',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 86,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: task.evidenceImages.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              task.evidenceImages[index],
                              width: 86,
                              height: 86,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 86,
                                height: 86,
                                color: ShiftIQColors.warmNeutral,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Cost breakdown
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ShiftIQColors.warmNeutral,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ShiftIQColors.borderSlate),
                      ),
                      child: Column(
                        children: [
                          _CostRow(
                            label: 'Mano de obra',
                            value: 'S/ ${task.laborPrice.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 6),
                          _CostRow(
                            label: 'Repuestos',
                            value: 'S/ ${task.productsTotal.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 16),
                          _CostRow(
                            label: 'Total de la tarea',
                            value: 'S/ ${task.grandTotal.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!task.isCompleted &&
                (onStartTask != null || onCompleteTask != null))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (task.isPending && onStartTask != null) {
                        onStartTask!();
                      } else if (task.isInProgress && onCompleteTask != null) {
                        onCompleteTask!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isInProgress
                          ? ShiftIQColors.preventiveGreen
                          : ShiftIQColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      task.isInProgress
                          ? Icons.check_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      task.isInProgress
                          ? loc.translate('complete')
                          : loc.translate('start'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ShiftIQColors.graphiteText,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductLineTile extends StatelessWidget {
  final WorkOrderTaskProduct product;

  const _ProductLineTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SparePartThumbnail(
            imageUrl: product.imageUrl,
            size: 38,
            borderRadius: 10,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.quantity} unid · ${product.formattedUnitPrice} c/u',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            product.formattedTotal,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ShiftIQColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _CostRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold
                ? ShiftIQColors.graphiteText
                : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: FontWeight.w700,
            color: isBold
                ? ShiftIQColors.primaryBlue
                : ShiftIQColors.graphiteText,
          ),
        ),
      ],
    );
  }
}
