import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_photo_gallery_viewer.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/spare_part_thumbnail.dart';

/// Modal bottom sheet displaying full task details: status, timestamps,
/// labor/parts cost breakdown, consumed spare parts, and evidence images.
class TaskDetailSheet extends StatefulWidget {
  final WorkOrderTask task;
  final VoidCallback? onAddProduct;
  final VoidCallback? onStartTask;
  final VoidCallback? onCompleteTask;
  final Future<WorkOrderTask?> Function(String productId, int newQuantity)?
      onUpdateProductQuantity;
  final Future<WorkOrderTask?> Function(String productId)? onRemoveProduct;
  final Future<WorkOrderTask?> Function(List<int> fileBytes, String fileName)?
      onAddEvidenceImage;
  final Future<WorkOrderTask?> Function(String imageUrl)? onRemoveEvidenceImage;

  const TaskDetailSheet({
    super.key,
    required this.task,
    this.onAddProduct,
    this.onStartTask,
    this.onCompleteTask,
    this.onUpdateProductQuantity,
    this.onRemoveProduct,
    this.onAddEvidenceImage,
    this.onRemoveEvidenceImage,
  });

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final ImagePicker _picker = ImagePicker();
  late WorkOrderTask _task;
  String? _busyProductId;
  bool _isUploadingImage = false;
  String? _actionError;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$min';
  }

  Future<void> _handleQuantityChange(
    WorkOrderTaskProduct product,
    int newQuantity,
  ) async {
    final updater = widget.onUpdateProductQuantity;
    if (updater == null || newQuantity < 1 || _busyProductId != null) return;

    setState(() {
      _busyProductId = product.productId;
      _actionError = null;
    });
    try {
      final updated = await updater(product.productId, newQuantity);
      if (!mounted) return;
      setState(() {
        if (updated != null) _task = updated;
        _busyProductId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _actionError = e.toString().replaceFirst('Exception: ', '');
        _busyProductId = null;
      });
    }
  }

  Future<void> _handleRemoveProduct(WorkOrderTaskProduct product) async {
    final remover = widget.onRemoveProduct;
    if (remover == null || _busyProductId != null) return;

    setState(() {
      _busyProductId = product.productId;
      _actionError = null;
    });
    try {
      final updated = await remover(product.productId);
      if (!mounted) return;
      setState(() {
        if (updated != null) _task = updated;
        _busyProductId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _actionError = e.toString().replaceFirst('Exception: ', '');
        _busyProductId = null;
      });
    }
  }

  Future<void> _pickAndUploadEvidence(ImageSource source) async {
    final uploader = widget.onAddEvidenceImage;
    if (uploader == null || _isUploadingImage) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _isUploadingImage = true;
        _actionError = null;
      });

      final updated = await uploader(bytes, picked.name);
      if (!mounted) return;
      setState(() {
        if (updated != null) _task = updated;
        _isUploadingImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _actionError = e.toString().replaceFirst('Exception: ', '');
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _handleRemoveEvidence(String imageUrl) async {
    final remover = widget.onRemoveEvidenceImage;
    if (remover == null || _isUploadingImage) return;

    setState(() {
      _isUploadingImage = true;
      _actionError = null;
    });
    try {
      final updated = await remover(imageUrl);
      if (!mounted) return;
      setState(() {
        if (updated != null) _task = updated;
        _isUploadingImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _actionError = e.toString().replaceFirst('Exception: ', '');
        _isUploadingImage = false;
      });
    }
  }

  void _showEvidenceSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: ShiftIQColors.primaryBlue,
                ),
                title: const Text('Tomar foto con cámara'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadEvidence(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: ShiftIQColors.primaryBlue,
                ),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadEvidence(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEvidenceGallery(int initialIndex) {
    ShiftIQPhotoGalleryViewer.open(
      context,
      imageUrls: _task.evidenceImages,
      initialIndex: initialIndex,
      title: 'Evidencia',
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final task = _task;
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
          maxHeight: MediaQuery.sizeOf(context).height * 0.84,
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
                        if (widget.onAddProduct != null &&
                            !task.isCompleted &&
                            task.products.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onAddProduct!();
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
                    if (_actionError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ShiftIQColors.severityCrimson.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _actionError!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ShiftIQColors.severityCrimson,
                          ),
                        ),
                      ),
                    ],
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
                            if (widget.onAddProduct != null &&
                                !task.isCompleted) ...[
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onAddProduct!();
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
                              _ProductLineTile(
                                product: task.products[i],
                                isBusy:
                                    _busyProductId == task.products[i].productId,
                                canEdit: !task.isCompleted &&
                                    widget.onUpdateProductQuantity != null,
                                onDecrement: () => _handleQuantityChange(
                                  task.products[i],
                                  task.products[i].quantity - 1,
                                ),
                                onIncrement: () => _handleQuantityChange(
                                  task.products[i],
                                  task.products[i].quantity + 1,
                                ),
                                onRemove: widget.onRemoveProduct != null
                                    ? () =>
                                        _handleRemoveProduct(task.products[i])
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),

                    if (task.evidenceImages.isNotEmpty ||
                        (widget.onAddEvidenceImage != null &&
                            !task.isCompleted)) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Evidencia (${task.evidenceImages.length})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                          if (widget.onAddEvidenceImage != null &&
                              !task.isCompleted)
                            TextButton.icon(
                              onPressed: _isUploadingImage
                                  ? null
                                  : _showEvidenceSourcePicker,
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
                              icon: Icon(
                                _isUploadingImage
                                    ? Icons.cloud_upload_outlined
                                    : Icons.add_a_photo_outlined,
                                size: 15,
                              ),
                              label: Text(
                                _isUploadingImage
                                    ? 'Subiendo...'
                                    : 'Agregar foto',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (task.evidenceImages.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: ShiftIQColors.borderSlate),
                          ),
                          child: const Text(
                            'Sin fotos de evidencia todavía.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 92,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: task.evidenceImages.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) {
                              final url = task.evidenceImages[index];
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _openEvidenceGallery(index),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        url,
                                        width: 92,
                                        height: 92,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          width: 92,
                                          height: 92,
                                          color: ShiftIQColors.warmNeutral,
                                          child: const Icon(
                                            Icons.broken_image_outlined,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (widget.onRemoveEvidenceImage != null &&
                                      !task.isCompleted)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: _isUploadingImage
                                            ? null
                                            : () => _handleRemoveEvidence(url),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withValues(alpha: 0.65),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
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
                (widget.onStartTask != null || widget.onCompleteTask != null))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (task.isPending && widget.onStartTask != null) {
                        widget.onStartTask!();
                      } else if (task.isInProgress &&
                          widget.onCompleteTask != null) {
                        widget.onCompleteTask!();
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
  final bool isBusy;
  final bool canEdit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback? onRemove;

  const _ProductLineTile({
    required this.product,
    required this.isBusy,
    required this.canEdit,
    required this.onDecrement,
    required this.onIncrement,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          Row(
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
          if (canEdit) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Quitar repuesto',
                    visualDensity: VisualDensity.compact,
                    onPressed: isBusy ? null : onRemove,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: ShiftIQColors.severityCrimson,
                    ),
                  ),
                const SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: ShiftIQColors.warmNeutral,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ShiftIQColors.borderSlate),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed:
                            !isBusy && product.quantity > 1 ? onDecrement : null,
                        icon: const Icon(Icons.remove_rounded, size: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '${product.quantity}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ShiftIQColors.graphiteText,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: !isBusy ? onIncrement : null,
                        icon: const Icon(Icons.add_rounded, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
