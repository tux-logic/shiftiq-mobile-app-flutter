import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Visual map pin picker for capturing branch latitude and longitude without manual input.
class BranchLocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final ValueChanged<LatLng> onLocationPicked;

  const BranchLocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationPicked,
  });

  @override
  State<BranchLocationPicker> createState() => _BranchLocationPickerState();
}

class _BranchLocationPickerState extends State<BranchLocationPicker> {
  LatLng? _pickedPoint;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _pickedPoint = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _pickedPoint ?? const LatLng(-12.0865, -76.9905);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pin branch location on map',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ShiftIQColors.graphiteText,
              ),
            ),
            if (_pickedPoint != null)
              Text(
                '${_pickedPoint!.latitude.toStringAsFixed(4)}, ${_pickedPoint!.longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ShiftIQColors.primaryBlue,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 12.5,
                onTap: (_, point) {
                  setState(() => _pickedPoint = point);
                  widget.onLocationPicked(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tuxlogic.shiftiq.mobile',
                ),
                if (_pickedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pickedPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: ShiftIQColors.primaryBlue,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
