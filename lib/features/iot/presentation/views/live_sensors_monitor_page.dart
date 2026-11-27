import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/controllers/telemetry_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/widgets/sensor_gauge_card.dart';

class LiveSensorsMonitorPage extends StatefulWidget {
  final String vehiclePlate;
  final String? vehicleId;
  final TelemetryViewModel viewModel;

  const LiveSensorsMonitorPage({
    super.key,
    required this.vehiclePlate,
    this.vehicleId,
    required this.viewModel,
  });

  @override
  State<LiveSensorsMonitorPage> createState() => _LiveSensorsMonitorPageState();
}

class _LiveSensorsMonitorPageState extends State<LiveSensorsMonitorPage> {
  String get _targetId => widget.vehicleId ?? widget.vehiclePlate;

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadLiveSensors(_targetId);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final loc = AppLocalizations.of(context);
        final sensors = widget.viewModel.liveSensors;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          body: ShiftIQCollapsibleHeaderBody(
            header: ShiftIQPageHeader(
              title: loc.translate('iot_latest_snapshot_title'),
              subtitle:
                  '${loc.translate('iot_vehicle_label')} ${widget.vehiclePlate} · ${loc.translate('iot_recorded_reading')}',
              showBackButton: true,
            ),
            body: ShiftIQPullToRefresh(
                  onRefresh: () =>
                      widget.viewModel.loadLiveSensors(_targetId),
                  skeleton: const ShiftIQSkeletonCardList(itemCount: 3),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Snapshot Info Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ShiftIQColors.borderSlate,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history_toggle_off_rounded,
                        size: 16,
                        color: ShiftIQColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.translate('iot_latest_snapshot_synced'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        loc.translate('iot_pull_to_refresh'),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section Title
                Text(
                  loc.translate('iot_latest_snapshot_readings'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),

                // Grid of Sensor Gauges
                if (sensors.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        children: [
                          const ShiftIQEmptyStateIcon(),
                          const SizedBox(height: 14),
                          Text(
                            loc.translate('iot_no_snapshots_recorded'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.translate('iot_pull_down_for_readings'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
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
                ),
          ),
        );
      },
    );
  }
}
