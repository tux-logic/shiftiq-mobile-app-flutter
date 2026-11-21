import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/entities/customer_registration.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/controllers/appointments_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/widgets/create_appointment_modal.dart';

class CustomerDirectoryPage extends StatefulWidget {
  final String branchId;
  final AppointmentsViewModel viewModel;

  const CustomerDirectoryPage({
    super.key,
    required this.branchId,
    required this.viewModel,
  });

  @override
  State<CustomerDirectoryPage> createState() => _CustomerDirectoryPageState();
}

class _CustomerDirectoryPageState extends State<CustomerDirectoryPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadCustomers(widget.branchId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    widget.viewModel.loadCustomers(widget.branchId, query: val);
  }

  void _openCreateAppointment({CustomerRegistration? customer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateAppointmentModal(
        branchId: widget.branchId,
        viewModel: widget.viewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: Column(
        children: [
          ShiftIQPageHeader(
            title: loc.translate('tooltip_customer_directory'),
            subtitle: 'Directorio de clientes y vehículos',
            showBackButton: true,
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final customers = widget.viewModel.customers;
                final isLoading = widget.viewModel.isLoading;

                return Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: loc.translate('search_customer_hint'),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: ShiftIQColors.borderSlate,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: ShiftIQColors.borderSlate,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Summary line
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.supervised_user_circle_outlined,
                            size: 16,
                            color: ShiftIQColors.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${customers.length} Clientes / Vehículos Registrados',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

              // List of customers
              Expanded(
                child: ShiftIQPullToRefresh(
                  onRefresh: () => widget.viewModel.loadCustomers(
                    widget.branchId,
                    query: _searchController.text,
                  ),
                  skeleton: const ShiftIQSkeletonCardList(),
                  child: ShiftIQContentTransition(
                    child: isLoading && customers.isEmpty
                        ? const ShiftIQSkeletonCardList(
                            key: ValueKey('cust_loading'),
                          )
                        : customers.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(32, 72, 32, 100),
                              children: [
                                const Center(
                                  child: ShiftIQEmptyStateIcon(),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No se encontraron clientes',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: ShiftIQColors.graphiteText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Prueba con otro término de búsqueda'
                                      : 'No hay registros en esta sede',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                              itemCount: customers.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final customer = customers[index];
                                return _buildCustomerCard(customer);
                              },
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
      ),
      floatingActionButton: ShiftIQPrimaryPillButton(
        label: loc.translate('new_appointment'),
        icon: Icons.add_rounded,
        onPressed: () => _openCreateAppointment(),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerRegistration customer) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.neutralBorder),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withAlpha(20),
                  child: Text(
                    customer.customerName.isNotEmpty
                        ? customer.customerName[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.customerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: AppColors.neutralLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer.phone.isNotEmpty
                                ? customer.phone
                                : 'Sin teléfono registrado',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutralLight,
                            ),
                          ),
                          if (customer.phone.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                ShiftIQToast.show(
                                  context,
                                  message:
                                      'Contactando a ${customer.customerName} (${customer.phone})',
                                  type: ShiftIQToastType.info,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.green.withAlpha(60),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 11,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Llamar',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutralDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    customer.vehiclePlate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neutralBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 14,
                    color: AppColors.neutralLight,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      customer.vehicleModel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ),
                  if (customer.email.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      customer.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutralLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _openCreateAppointment(customer: customer),
                icon: const Icon(Icons.calendar_today_outlined, size: 14),
                label: Text(AppLocalizations.of(context).translate('schedule_appointment')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
