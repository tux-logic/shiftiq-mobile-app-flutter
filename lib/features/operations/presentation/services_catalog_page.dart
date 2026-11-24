import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/usecases/manage_services.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/models/workshop_service.dart';

/// Branch-scoped workshop labor services catalog management page.
class ServicesCatalogPage extends StatefulWidget {
  final String branchId;
  final ManageServices? manageServices;

  const ServicesCatalogPage({
    super.key,
    required this.branchId,
    this.manageServices,
  });

  @override
  State<ServicesCatalogPage> createState() => _ServicesCatalogPageState();
}

class _ServicesCatalogPageState extends State<ServicesCatalogPage> {
  late final ManageServices _manageServices;
  List<WorkshopService> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _manageServices = widget.manageServices ?? getIt<ManageServices>();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await _manageServices.getBranchServices(widget.branchId);
      if (!mounted) return;
      setState(() {
        _services = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo cargar el catálogo de servicios.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openServiceForm({WorkshopService? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(2) : '',
    );
    var isSaving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existing == null
                              ? 'Nuevo Servicio'
                              : 'Editar Servicio',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ShiftIQColors.graphiteText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(sheetContext).pop(false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del servicio *',
                        hintText: 'Ej. Alineación y Balanceo Computarizado',
                        prefixIcon: Icon(Icons.design_services_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingrese el nombre del servicio'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio (S/) *',
                        hintText: 'Ej. 80.00',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (val) {
                        final parsed = double.tryParse(
                          (val ?? '').trim().replaceAll(',', '.'),
                        );
                        if (parsed == null || parsed <= 0) {
                          return 'Ingrese un precio mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSaving = true);
                                final name = nameCtrl.text.trim();
                                final price = double.parse(
                                  priceCtrl.text.trim().replaceAll(',', '.'),
                                );
                                try {
                                  if (existing == null) {
                                    await _manageServices.createService(
                                      branchId: widget.branchId,
                                      name: name,
                                      price: price,
                                    );
                                  } else {
                                    await _manageServices.updateService(
                                      serviceId: existing.id,
                                      name: name,
                                      price: price,
                                    );
                                  }
                                  if (sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop(true);
                                  }
                                } catch (e) {
                                  setModalState(() => isSaving = false);
                                  if (sheetContext.mounted) {
                                    ShiftIQToast.show(
                                      sheetContext,
                                      message:
                                          'No se pudo guardar el servicio: $e',
                                      type: ShiftIQToastType.error,
                                    );
                                  }
                                }
                              },
                        icon: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          existing == null
                              ? 'Guardar Servicio'
                              : 'Actualizar Servicio',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    priceCtrl.dispose();

    if (saved == true && mounted) {
      ShiftIQToast.show(
        context,
        message: existing == null
            ? 'Servicio registrado en la sede'
            : 'Servicio actualizado',
        type: ShiftIQToastType.success,
      );
      await _loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: ShiftIQCollapsibleHeaderBody(
        header: const ShiftIQPageHeader(
          title: 'Catálogo de Servicios',
          subtitle: 'Servicios de mano de obra de la sede',
          showBackButton: true,
        ),
        body: ShiftIQPullToRefresh(
          onRefresh: _loadServices,
          skeleton: const ShiftIQSkeletonCardList(itemCount: 4),
          child: _isLoading && _services.isEmpty
              ? const ShiftIQSkeletonCardList(itemCount: 4)
              : _errorMessage != null && _services.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(32, 72, 32, 100),
                      children: [
                        const Center(child: ShiftIQEmptyStateIcon()),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    )
                  : _services.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(32, 72, 32, 100),
                          children: const [
                            Center(child: ShiftIQEmptyStateIcon()),
                            SizedBox(height: 12),
                            Text(
                              'Sin servicios registrados',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: ShiftIQColors.graphiteText,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Crea los servicios que ofrece esta sede para usarlos al agendar citas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: _services.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: ShiftIQColors.borderSlate,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: ShiftIQColors.primaryBlue
                                          .withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.design_services_outlined,
                                      color: ShiftIQColors.primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: ShiftIQColors.graphiteText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'S/ ${service.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: ShiftIQColors.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Editar servicio',
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: Color(0xFF64748B),
                                    ),
                                    onPressed: () =>
                                        _openServiceForm(existing: service),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ),
      floatingActionButton: ShiftIQPrimaryPillButton(
        label: 'Nuevo Servicio',
        icon: Icons.add_rounded,
        onPressed: () => _openServiceForm(),
      ),
    );
  }
}
