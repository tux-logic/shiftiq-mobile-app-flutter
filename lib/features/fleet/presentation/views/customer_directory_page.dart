import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      appBar: AppBar(
        title: const Text(
          'Directorio de Clientes B2B',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.viewModel.loadCustomers(
              widget.branchId,
              query: _searchController.text,
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final customers = widget.viewModel.customers;
          final isLoading = widget.viewModel.isLoading;

          return Column(
            children: [
              // Search bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, placa o teléfono...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.neutralBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // KPI Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AppColors.neutralBorder),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.supervised_user_circle_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${customers.length} Clientes / Vehículos Registrados',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),

              // List of customers
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : customers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_search_outlined,
                                  size: 48,
                                  color: AppColors.neutralLight,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No se encontraron clientes',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutralDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Prueba con otro término de búsqueda'
                                      : 'No hay registros en esta sede',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.neutralLight,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: customers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              return _buildCustomerCard(customer);
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_customer_directory',
        onPressed: () => _openCreateAppointment(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                      Text(
                        customer.phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutralLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                label: const Text('Agendar Cita'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
