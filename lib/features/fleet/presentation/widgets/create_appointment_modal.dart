import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/create_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/entities/customer_registration.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/controllers/appointments_view_model.dart';

class CreateAppointmentModal extends StatefulWidget {
  final String branchId;
  final AppointmentsViewModel viewModel;

  const CreateAppointmentModal({
    super.key,
    required this.branchId,
    required this.viewModel,
  });

  @override
  State<CreateAppointmentModal> createState() => _CreateAppointmentModalState();
}

class _CreateAppointmentModalState extends State<CreateAppointmentModal> {
  final _formKey = GlobalKey<FormState>();

  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _vehiclePlateCtrl = TextEditingController();
  final _vehicleModelCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _selectedBay = 1;
  String _selectedService = 'Mantenimiento Preventivo 30,000 km';
  CustomerRegistration? _selectedCustomer;

  final List<String> _serviceOptions = [
    'Mantenimiento Preventivo 30,000 km',
    'Diagnóstico Computarizado OBD-II',
    'Mantenimiento de Frenos y Cambio DOT4',
    'Suspensión y Dirección Hidráulica',
    'Cambio de Aceite 5W-30 y Filtros',
    'Alineamiento 3D y Balanceo',
    'Reparación de Motor / Afinamiento',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.viewModel.selectedDate;
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _vehiclePlateCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onCustomerSelected(CustomerRegistration? cust) {
    setState(() {
      _selectedCustomer = cust;
      if (cust != null) {
        _customerNameCtrl.text = cust.customerName;
        _customerPhoneCtrl.text = cust.phone;
        _vehiclePlateCtrl.text = cust.vehiclePlate;
        _vehicleModelCtrl.text = cust.vehicleModel;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final command = CreateAppointmentCommand(
      branchId: widget.branchId,
      customerId: _selectedCustomer?.customerId ?? 'cust-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _customerNameCtrl.text,
      customerPhone: _customerPhoneCtrl.text.isNotEmpty ? _customerPhoneCtrl.text : '+51 900 000 000',
      vehicleId: _selectedCustomer?.id ?? 'veh-${DateTime.now().millisecondsSinceEpoch}',
      vehiclePlate: _vehiclePlateCtrl.text,
      vehicleModel: _vehicleModelCtrl.text.isNotEmpty ? _vehicleModelCtrl.text : 'Vehículo General',
      scheduledStart: scheduledDateTime,
      serviceType: _selectedService,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      bayNumber: _selectedBay,
    );

    final success = await widget.viewModel.createAppointment(command, widget.branchId);
    if (!mounted) return;

    if (success) {
      final loc = AppLocalizations.of(context);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('appointment_scheduled_success')),
          backgroundColor: AppColors.stateSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final customers = widget.viewModel.customers;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agendar Nueva Cita',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick select existing customer
              if (customers.isNotEmpty) ...[
                DropdownButtonFormField<CustomerRegistration>(
                  initialValue: _selectedCustomer,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: loc.translate('select_registered_customer_optional'),
                    prefixIcon: const Icon(Icons.person_search_outlined),
                  ),
                  items: [
                    DropdownMenuItem<CustomerRegistration>(
                      value: null,
                      child: Text(loc.translate('new_customer_manual')),
                    ),
                    ...customers.map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.customerName} (${c.vehiclePlate})'),
                      ),
                    ),
                  ],
                  onChanged: _onCustomerSelected,
                ),
                const SizedBox(height: 12),
              ],

              // Customer Name & Phone
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _customerNameCtrl,
                      decoration: InputDecoration(
                        labelText: loc.translate('full_name_required'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingrese el cliente'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _customerPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.translate('phone'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Plate & Vehicle Model
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _vehiclePlateCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: loc.translate('plate_required'),
                        hintText: loc.translate('plate_hint'),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingrese placa'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _vehicleModelCtrl,
                      decoration: InputDecoration(
                        labelText: loc.translate('model_brand'),
                        hintText: loc.translate('model_brand_hint'),
                        prefixIcon: const Icon(Icons.directions_car_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date and Time picker row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutralBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutralBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bay Selection
              Text(
                'Bahía Asignada:',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [1, 2, 3, 4].map((bay) {
                  final isSelected = _selectedBay == bay;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('${loc.translate('bay')} $bay'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.neutralDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedBay = bay);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Service selection dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedService,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: loc.translate('service_type_job'),
                  prefixIcon: const Icon(Icons.build_circle_outlined),
                ),
                items: _serviceOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedService = val);
                },
              ),
              const SizedBox(height: 12),

              // Notes field
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: loc.translate('symptoms_notes'),
                  hintText: loc.translate('symptoms_notes_hint'),
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 18),

              // Action button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Confirmar y Agendar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
