import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/create_work_order_use_case.dart';

class CreateWorkOrderPage extends StatefulWidget {
  final String branchId;
  final CreateWorkOrderUseCase? createWorkOrderUseCase;
  final String? initialPlate;
  final String? initialCustomerName;
  final String? initialPhone;
  final String? initialModel;
  final String? initialDiagnostic;

  const CreateWorkOrderPage({
    super.key,
    required this.branchId,
    this.createWorkOrderUseCase,
    this.initialPlate,
    this.initialCustomerName,
    this.initialPhone,
    this.initialModel,
    this.initialDiagnostic,
  });

  @override
  State<CreateWorkOrderPage> createState() => _CreateWorkOrderPageState();
}

class _CreateWorkOrderPageState extends State<CreateWorkOrderPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _plateController;
  late final TextEditingController _modelController;
  late final TextEditingController _customerController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mileageController;
  late final TextEditingController _diagnosticController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.initialPlate ?? 'D2A-789');
    _modelController = TextEditingController(text: widget.initialModel ?? 'Toyota Yaris 2022');
    _customerController = TextEditingController(text: widget.initialCustomerName ?? 'Mario Salcedo');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '+51 965 432 109');
    _mileageController = TextEditingController(text: '35000');
    _diagnosticController = TextEditingController(
      text: widget.initialDiagnostic ?? 'Mantenimiento preventivo y cambio de bujías',
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _customerController.dispose();
    _phoneController.dispose();
    _mileageController.dispose();
    _diagnosticController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final useCase =
          widget.createWorkOrderUseCase ?? getIt<CreateWorkOrderUseCase>();

      await useCase.execute(
        branchId: widget.branchId,
        vehicleId: 'veh-${DateTime.now().millisecondsSinceEpoch}',
        customerId: 'cust-${DateTime.now().millisecondsSinceEpoch}',
        vehiclePlate: _plateController.text.trim().toUpperCase(),
        vehicleModel: _modelController.text.trim(),
        customerName: _customerController.text.trim(),
        mileageIn: int.tryParse(_mileageController.text) ?? 0,
        diagnosticSummary: _diagnosticController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orden de Trabajo creada exitosamente en el taller'),
            backgroundColor: ShiftIQColors.preventiveGreen,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear orden: ${e.toString()}'),
            backgroundColor: ShiftIQColors.severityCrimson,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      appBar: AppBar(
        title: const Text('Nueva Orden de Trabajo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ShiftIQColors.borderSlate),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATOS DEL VEHÍCULO Y CLIENTE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _plateController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Placa *',
                              hintText: 'ABC-123',
                              prefixIcon: Icon(Icons.pin),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Ingrese la placa'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _modelController,
                            decoration: const InputDecoration(
                              labelText: 'Marca y Modelo *',
                              hintText: 'Toyota Hilux 2021',
                              prefixIcon: Icon(Icons.directions_car),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Ingrese el modelo'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Cliente / Dueño *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Ingrese el nombre del cliente'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _mileageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Kilometraje Ingreso *',
                              prefixIcon: Icon(Icons.speed),
                              suffixText: 'km',
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Ingrese el kilometraje'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _diagnosticController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Diagnóstico Inicial / Motivo de Ingreso *',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Describa el diagnóstico inicial'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShiftIQColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined),
                          SizedBox(width: 8),
                          Text(
                            'ABRIR ORDEN DE TRABAJO',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

