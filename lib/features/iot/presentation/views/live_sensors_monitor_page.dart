import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/controllers/telemetry_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/widgets/sensor_gauge_card.dart';

class LiveSensorsMonitorPage extends StatefulWidget {
  final String vehiclePlate;
  final TelemetryViewModel viewModel;

  const LiveSensorsMonitorPage({
    super.key,
    required this.vehiclePlate,
    required this.viewModel,
  });

  @override
  State<LiveSensorsMonitorPage> createState() => _LiveSensorsMonitorPageState();
}

class _LiveSensorsMonitorPageState extends State<LiveSensorsMonitorPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadLiveSensors(widget.vehiclePlate);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final sensors = widget.viewModel.liveSensors;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Telemetría en Vivo OBD-II',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Vehículo ${widget.vehiclePlate} · Dongle ELM327',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: AppLocalizations.of(context).translate('tooltip_refresh_sensors'),
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    widget.viewModel.loadLiveSensors(widget.vehiclePlate),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dongle Connection Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.preventiveGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ShiftIQColors.preventiveGreen.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: ShiftIQColors.preventiveGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Dongle ELM327 Bluetooth Conectado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ShiftIQColors.preventiveGreen,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Frecuencia: 5 Hz',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section Title
                const Text(
                  'PARÁMETROS DEL MOTOR EN TIEMPO REAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),

                // Grid of Sensor Gauges
                if (sensors.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: sensors.length,
                    itemBuilder: (context, index) {
                      return SensorGaugeCard(sensor: sensors[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
